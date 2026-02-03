{pkgs, ...}:
pkgs.writeShellApplication {
  name = "nixos-anywhere-install";

  runtimeInputs = with pkgs; [
    nixos-anywhere
    sops
    age
    ssh-to-age
    openssh
    git
    nix
    alejandra
  ];

  text = ''
    # ---------------------------------------------------------------------------
    # Configuration defaults
    # ---------------------------------------------------------------------------
    FLAKE_DIR="''${FLAKE_DIR:-$(git rev-parse --show-toplevel)}"
    SECRETS_DIR="''${SECRETS_DIR:-$HOME/.config/nix-secrets}"
    HOSTNAME=""
    TARGET_USER="nixos"
    TARGET_DESTINATION=""
    USERNAME="''${USERNAME:-$(whoami)}"
    SSH_PORT=22

    # ---------------------------------------------------------------------------
    # Colours
    # ---------------------------------------------------------------------------
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'

    log()   { echo -e "''${GREEN}[INFO]''${NC} $*"; }
    warn()  { echo -e "''${YELLOW}[WARN]''${NC} $*"; }
    error() { echo -e "''${RED}[ERROR]''${NC} $*"; exit 1; }

    # ---------------------------------------------------------------------------
    # yes_or_no  –  returns 0 (true) on y/Y/yes/Enter, 1 (false) on n/N/no
    # ---------------------------------------------------------------------------
    yes_or_no() {
      local prompt="$1"
      while true; do
        read -r -p "$prompt [Y/n] " reply
        reply="''${reply:-Y}"          # default Y
        case "$reply" in
          [Yy]|[Yy][Ee][Ss]) return 0 ;;
          [Nn]|[Nn][Oo])     return 1 ;;
          *) echo "Please answer y or n." ;;
        esac
      done
    }

    # ---------------------------------------------------------------------------
    # Usage
    # ---------------------------------------------------------------------------
    usage() {
      cat <<EOF
    Usage: nixos-anywhere-install -n HOSTNAME -d DEST [OPTIONS]

    Required:
      -n, --hostname    HOSTNAME     NixOS configuration hostname to install
      -d, --destination DEST         IP or domain of the target machine

    Options:
      -t, --target-user USER         SSH user on the target ISO (default: nixos)
      -u, --user        USERNAME     Username on the installed system (default: whoami)
      -p, --port        PORT         SSH port (default: 22)
      -f, --flake-dir   DIR          Path to flake directory (default: git repo root)
      -s, --secrets-dir DIR          Path to nix-secrets directory (default: ~/.config/nix-secrets)
          --debug                    Enable xtrace debug output
      -h, --help                     Show this help

    Example:
      nixos-anywhere-install -n gaia -d 192.168.8.101
    EOF
    }

    # ---------------------------------------------------------------------------
    # Argument parsing
    # ---------------------------------------------------------------------------
    while [[ $# -gt 0 ]]; do
      case $1 in
        -n | --hostname)      HOSTNAME="$2";            shift 2 ;;
        -d | --destination)   TARGET_DESTINATION="$2";  shift 2 ;;
        -t | --target-user)   TARGET_USER="$2";         shift 2 ;;
        -u | --user)          USERNAME="$2";            shift 2 ;;
        -p | --port)          SSH_PORT="$2";            shift 2 ;;
        -f | --flake-dir)     FLAKE_DIR="$2";           shift 2 ;;
        -s | --secrets-dir)   SECRETS_DIR="$2";         shift 2 ;;
             --debug)         set -x;                   shift    ;;
        -h | --help)          usage;                    exit 0   ;;
        *) error "Unknown option: $1  (use -h)" ;;
      esac
    done

    # ---------------------------------------------------------------------------
    # Validation
    # ---------------------------------------------------------------------------
    [[ -z "$HOSTNAME"           ]] && error "Missing required argument: --hostname"
    [[ -z "$TARGET_DESTINATION" ]] && error "Missing required argument: --destination"
    [[ ! -d "$FLAKE_DIR" ]]                && error "Flake directory does not exist: $FLAKE_DIR"
    [[ ! -d "$SECRETS_DIR" ]]              && error "Secrets directory does not exist: $SECRETS_DIR"
    [[ ! -f "$FLAKE_DIR/flake.nix" ]]      && error "No flake.nix found in $FLAKE_DIR"
    [[ ! -f "$SECRETS_DIR/secrets.yaml" ]] && error "No secrets.yaml found in $SECRETS_DIR"

    log "Hostname        : $HOSTNAME"
    log "Target          : $TARGET_USER@$TARGET_DESTINATION"
    log "SSH port        : $SSH_PORT"
    log "Flake directory : $FLAKE_DIR"
    log "Secrets dir     : $SECRETS_DIR"

    # ---------------------------------------------------------------------------
    # SSH / SCP command bases
    # ---------------------------------------------------------------------------
    ssh_cmd="ssh -oControlPath=none -oport=$SSH_PORT -oForwardAgent=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"
    ssh_root_cmd="$ssh_cmd root@$TARGET_DESTINATION"
    ssh_user_cmd="$ssh_cmd $USERNAME@$TARGET_DESTINATION"
    scp_cmd="scp -oControlPath=none -oport=$SSH_PORT -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"

    # ---------------------------------------------------------------------------
    # Temp directory (cleaned up on exit)
    # ---------------------------------------------------------------------------
    TEMP_DIR=$(mktemp -d)
    trap 'rm -rf "$TEMP_DIR"' EXIT

    # ---------------------------------------------------------------------------
    # generate_ssh_keys  –  create ed25519 + rsa host key pairs and derive age key
    # ---------------------------------------------------------------------------
    generate_ssh_keys() {
      log "Generating SSH host keys for $HOSTNAME..."
      ssh-keygen -t ed25519 -f "$TEMP_DIR/ssh_host_ed25519_key" -N "" -C "root@$HOSTNAME"
      ssh-keygen -t rsa -b 4096 -f "$TEMP_DIR/ssh_host_rsa_key" -N "" -C "root@$HOSTNAME"

      AGE_KEY=$(ssh-to-age < "$TEMP_DIR/ssh_host_ed25519_key.pub")
      log "Derived age key : $AGE_KEY"
    }

    # ---------------------------------------------------------------------------
    # update_sops  –  edit .sops.yaml, re-encrypt secrets, commit & push both repos
    # ---------------------------------------------------------------------------
    update_sops() {
      local sops_yaml="$FLAKE_DIR/.sops.yaml"

      if grep -q "$AGE_KEY" "$sops_yaml"; then
        log "Age key already present in .sops.yaml – skipping edit"
      else
        log "Adding $HOSTNAME age key to .sops.yaml..."
        local last_def  last_ref
        last_def=$(grep -n "^  - &" "$sops_yaml" | tail -1 | cut -d: -f1)
        sed -i "''${last_def}a\  - \&$HOSTNAME $AGE_KEY" "$sops_yaml"

        last_ref=$(grep -n "^\s*- \*" "$sops_yaml" | tail -1 | cut -d: -f1)
        sed -i "''${last_ref}a\          - *$HOSTNAME" "$sops_yaml"
      fi

      log "Re-encrypting secrets..."
      sops updatekeys "$SECRETS_DIR/secrets.yaml"

      # commit & push .sops.yaml
      cd "$FLAKE_DIR"
      git add .sops.yaml
      git commit -m "feat(sops): add $HOSTNAME age key to .sops.yaml"
      git push

      # commit & push secrets
      cd "$SECRETS_DIR"
      git add secrets.yaml
      git commit -m "feat(secrets): add $HOSTNAME age key and re-encrypt"
      git push
      cd "$FLAKE_DIR"
    }

    # ---------------------------------------------------------------------------
    # add_ssh_keys_to_secrets  –  interactive: user pastes keys, then commit/push/update
    # ---------------------------------------------------------------------------
    add_ssh_keys_to_secrets() {
      warn "Add the SSH host keys to secrets.yaml now."
      echo ""
      echo "  cd $SECRETS_DIR"
      echo "  sops secrets.yaml"
      echo ""
      echo "Under 'systems:', add:"
      echo "  $HOSTNAME:"
      echo "    ssh:"
      echo "      public_key:  $(cat "$TEMP_DIR/ssh_host_ed25519_key.pub")"
      echo "      private_key: <contents of the private key below>"
      echo ""
      echo "--- private key (copy everything between the markers) ---"
      cat "$TEMP_DIR/ssh_host_ed25519_key"
      echo "--- end ---"
      echo ""
      read -r -p "Press Enter once you have saved and exited the editor..."

      cd "$SECRETS_DIR"
      git add secrets.yaml
      git commit -m "feat(secrets): add $HOSTNAME SSH host keys"
      git push
      cd "$FLAKE_DIR"

      log "Updating secrets flake input..."
      nix flake update secrets
    }

    # ---------------------------------------------------------------------------
    # extract_keys_from_secrets  –  pull previously committed keys back out of sops
    # ---------------------------------------------------------------------------
    extract_keys_from_secrets() {
      log "Extracting $HOSTNAME SSH keys from secrets..."
      sops -d --extract "[\"systems\"][\"$HOSTNAME\"][\"ssh\"][\"private_key\"]" \
        "$SECRETS_DIR/secrets.yaml" > "$TEMP_DIR/ssh_host_ed25519_key"
      sops -d --extract "[\"systems\"][\"$HOSTNAME\"][\"ssh\"][\"public_key\"]" \
        "$SECRETS_DIR/secrets.yaml" > "$TEMP_DIR/ssh_host_ed25519_key.pub"
      chmod 600 "$TEMP_DIR/ssh_host_ed25519_key"

      AGE_KEY=$(ssh-to-age < "$TEMP_DIR/ssh_host_ed25519_key.pub")
      log "Extracted age key : $AGE_KEY"
    }

    # ---------------------------------------------------------------------------
    # extract_luks_password  –  pull the shared LUKS passphrase from sops
    # ---------------------------------------------------------------------------
    extract_luks_password() {
      log "Extracting LUKS password..."
      LUKS_PASSWORD_FILE="$TEMP_DIR/luks-password.txt"
      if ! sops -d --extract '["systems"]["luksPassword"]' \
            "$SECRETS_DIR/secrets.yaml" > "$LUKS_PASSWORD_FILE" 2>/dev/null; then
        error "Failed to extract systems.luksPassword from secrets"
      fi
      chmod 600 "$LUKS_PASSWORD_FILE"
      log "LUKS password extracted"
    }

    # ---------------------------------------------------------------------------
    # prepare_extra_files  –  lay out the directory tree nixos-anywhere will copy
    # ---------------------------------------------------------------------------
    prepare_extra_files() {
      EXTRA_FILES_DIR="$TEMP_DIR/extra-files"

      # SSH host keys → /etc/ssh
      install -d -m 755 "$EXTRA_FILES_DIR/etc/ssh"
      cp "$TEMP_DIR/ssh_host_ed25519_key"     "$EXTRA_FILES_DIR/etc/ssh/"
      cp "$TEMP_DIR/ssh_host_ed25519_key.pub" "$EXTRA_FILES_DIR/etc/ssh/"
      # RSA keys only exist when we generated them in this run
      if [[ -f "$TEMP_DIR/ssh_host_rsa_key" ]]; then
        cp "$TEMP_DIR/ssh_host_rsa_key"     "$EXTRA_FILES_DIR/etc/ssh/"
        cp "$TEMP_DIR/ssh_host_rsa_key.pub" "$EXTRA_FILES_DIR/etc/ssh/"
      fi
      chmod 600 "$EXTRA_FILES_DIR/etc/ssh/ssh_host_"*
      chmod 644 "$EXTRA_FILES_DIR/etc/ssh/ssh_host_"*.pub
    }

    # ---------------------------------------------------------------------------
    # run_nixos_anywhere  –  wipe known_hosts entry, confirm, execute
    # ---------------------------------------------------------------------------
    run_nixos_anywhere() {
      # Strip any old host-key entries for this target so SSH does not refuse
      sed -i "/$HOSTNAME/d; /$TARGET_DESTINATION/d" ~/.ssh/known_hosts 2>/dev/null || true

      log "Installation summary:"
      echo "  Hostname    : $HOSTNAME"
      echo "  Target      : $TARGET_USER@$TARGET_DESTINATION"
      echo "  SSH port    : $SSH_PORT"
      echo "  Flake       : $FLAKE_DIR#$HOSTNAME"
      echo "  Age key     : $AGE_KEY"
      echo "  Extra files : $EXTRA_FILES_DIR"
      echo ""
      warn "This will COMPLETELY WIPE the target disk!"
      if ! yes_or_no "Continue with installation?"; then
        error "Installation cancelled by user"
      fi

      log "Running nixos-anywhere..."
      nixos-anywhere \
        --flake "$FLAKE_DIR#$HOSTNAME" \
        --ssh-port "$SSH_PORT" \
        --post-kexec-ssh-port "$SSH_PORT" \
        --disk-encryption-keys /tmp/secret.key "$LUKS_PASSWORD_FILE" \
        --extra-files "$EXTRA_FILES_DIR" \
        "$TARGET_USER@$TARGET_DESTINATION"
    }

    # ---------------------------------------------------------------------------
    # generate_hardware_config  –  ssh into target, generate, scp back, format, commit
    # ---------------------------------------------------------------------------
    generate_hardware_config() {
      local hw_file="$FLAKE_DIR/systems/x86_64-linux/$HOSTNAME/hardware.nix"

      log "Generating hardware config on $TARGET_DESTINATION..."
      $ssh_root_cmd "nixos-generate-config --no-filesystems --root /mnt"

      log "Copying hardware config back..."
      $scp_cmd "root@$TARGET_DESTINATION:/mnt/etc/nixos/hardware-configuration.nix" "$hw_file"

      log "Formatting with alejandra..."
      alejandra "$hw_file"

      if yes_or_no "Commit and push hardware config?"; then
        cd "$FLAKE_DIR"
        git add "systems/x86_64-linux/$HOSTNAME/hardware.nix"
        git commit -m "feat($HOSTNAME): add generated hardware config"
        git push
        log "Hardware config committed and pushed"
      else
        log "Skipping commit/push – hardware config is at $hw_file"
      fi
    }

    # ---------------------------------------------------------------------------
    # post_install  –  wait for reboot, scp flake, run nh os switch
    # ---------------------------------------------------------------------------
    post_install() {
      warn "Wait until the machine ($HOSTNAME) has rebooted and press Enter when it is ready..."
      read -r -p ""

      # Host keys changed – strip the old ISO entries
      sed -i "/$HOSTNAME/d; /$TARGET_DESTINATION/d" ~/.ssh/known_hosts 2>/dev/null || true

      log "Copying flake to $HOSTNAME..."
      $scp_cmd -r "$FLAKE_DIR" "$USERNAME@$TARGET_DESTINATION:/home/$USERNAME/.config/nix-config"

      log "Running 'nh os switch' on $HOSTNAME..."
      $ssh_user_cmd "nh os switch -- --impure"

      log "Done!"
    }

    # ===========================================================================
    # Main
    # ===========================================================================

    # --- Phase 1: SSH keys & sops setup (interactive gates) ---
    if yes_or_no "Generate new SSH host keys for $HOSTNAME?"; then
      generate_ssh_keys

      if yes_or_no "Update .sops.yaml and re-encrypt secrets?"; then
        update_sops
      fi

      if yes_or_no "Add SSH host keys to secrets.yaml?"; then
        add_ssh_keys_to_secrets
      fi
    else
      # Keys already exist – pull them back out of secrets so extra-files works
      extract_keys_from_secrets
    fi

    # --- Phase 2: Install ---
    if yes_or_no "Run nixos-anywhere installation?"; then
      extract_luks_password
      prepare_extra_files
      run_nixos_anywhere
    fi

    # --- Phase 3: Hardware config ---
    if yes_or_no "Generate hardware config? (skip if rebuilding an existing machine)"; then
      generate_hardware_config
    fi

    # --- Phase 4: Post-install ---
    if yes_or_no "Copy config and rebuild immediately on $HOSTNAME?"; then
      post_install
    fi

    log "Done!"
  '';
}

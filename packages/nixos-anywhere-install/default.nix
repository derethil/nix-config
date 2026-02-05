{
  pkgs,
  lib,
  ...
}:
pkgs.writeShellApplication {
  name = "nixos-anywhere-install";

  runtimeInputs = lib.flatten (with pkgs; [
    nixos-anywhere
    sops
    age
    ssh-to-age
    git
    nix
    gnused
    alejandra
    (lib.optionals stdenv.isLinux [
      openssh
    ])
  ]);

  text = ''
    # ---------------------------------------------------------------------------
    # Configuration defaults
    # ---------------------------------------------------------------------------
    FLAKE_DIR="''${FLAKE_DIR:-$(git rev-parse --show-toplevel)}"
    SECRETS_DIR="''${SECRETS_DIR:-$HOME/.config/nix-secrets}"
    PERSIST_DIR=""
    HOSTNAME=""
    TARGET_USER="nixos"
    TARGET_DESTINATION=""
    USERNAME="''${USERNAME:-$(whoami)}"
    SSH_PORT=22
    BUILD_ON_REMOTE=false
    GENERATE_HW_CONFIG=false

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
      -i, --impermanence            Set persist directory to /persist
          --build-on-remote          Eval and build on the target machine instead of locally
          --debug                    Enable xtrace debug output
      -h, --help                     Show this help

    Example:
      nixos-anywhere-install -n gaia -d 192.168.8.101
    EOF
    }

    # ---------------------------------------------------------------------------
    # yes_or_no  – returns 0 on y/Y/yes/Enter, 1 on n/N/no
    # ---------------------------------------------------------------------------
    yes_or_no() {
      local prompt="$1"
      while true; do
        read -r -p "$prompt [Y/n] " reply
        reply="''${reply:-Y}"
        case "$reply" in
          [Yy]|[Yy][Ee][Ss]) return 0 ;;
          [Nn]|[Nn][Oo])     return 1 ;;
          *) echo "Please answer y or n." ;;
        esac
      done
    }

    # ---------------------------------------------------------------------------
    # Argument parsing
    # ---------------------------------------------------------------------------
    while [[ $# -gt 0 ]]; do
      case $1 in
        -d|--destination)   TARGET_DESTINATION="$2"; shift 2 ;;
        -t|--target-user)   TARGET_USER="$2"; shift 2 ;;
        -u|--user)          USERNAME="$2"; shift 2 ;;
        -p|--port)          SSH_PORT="$2"; shift 2 ;;
        -f|--flake-dir)     FLAKE_DIR="$2"; shift 2 ;;
        -n|--hostname)      HOSTNAME="$2"; shift 2 ;;
        -s|--secrets-dir)   SECRETS_DIR="$2"; shift 2 ;;
        -i|--impermanence)  PERSIST_DIR="/persist"; shift ;;
        --build-on-remote)  BUILD_ON_REMOTE=true; shift ;;
        --debug)            set -x; shift ;;
        -h|--help)          usage; exit 0 ;;
        *) error "Unknown option: $1 (use -h)" ;;
      esac
    done

    # ---------------------------------------------------------------------------
    # Validation
    # ---------------------------------------------------------------------------
    [[ -z "$HOSTNAME" ]] && error "Missing required argument: --hostname"
    [[ -z "$TARGET_DESTINATION" ]] && error "Missing required argument: --destination"
    [[ ! -d "$FLAKE_DIR" ]] && error "Flake directory does not exist: $FLAKE_DIR"
    [[ ! -d "$SECRETS_DIR" ]] && error "Secrets directory does not exist: $SECRETS_DIR"
    [[ ! -f "$FLAKE_DIR/flake.nix" ]] && error "No flake.nix found in $FLAKE_DIR"
    [[ ! -f "$SECRETS_DIR/secrets.yaml" ]] && error "No secrets.yaml found in $SECRETS_DIR"

    HW_FILE="$FLAKE_DIR/systems/x86_64-linux/$HOSTNAME/hardware.nix"

    log "Hostname        : $HOSTNAME"
    log "Target          : $TARGET_USER@$TARGET_DESTINATION"
    log "SSH port        : $SSH_PORT"
    log "Flake directory : $FLAKE_DIR"
    log "Secrets dir     : $SECRETS_DIR"
    log "Persist dir     : ''${PERSIST_DIR:-(none)}"
    log "Build on remote : $BUILD_ON_REMOTE"

    # ---------------------------------------------------------------------------
    # SSH / SCP base commands
    # ---------------------------------------------------------------------------
    ssh_base="ssh -oControlPath=none -oPort=$SSH_PORT -oForwardAgent=yes -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"
    ssh_user="$ssh_base $USERNAME@$TARGET_DESTINATION"
    scp_cmd="scp -oControlPath=none -oPort=$SSH_PORT -oStrictHostKeyChecking=no -oUserKnownHostsFile=/dev/null"

    # ---------------------------------------------------------------------------
    # Temp directory
    # ---------------------------------------------------------------------------
    TEMP_DIR=$(mktemp -d)
    eval "$(ssh-agent -s)"
    trap 'kill $SSH_AGENT_PID 2>/dev/null; rm -rf "$TEMP_DIR"' EXIT

    # ---------------------------------------------------------------------------
    # SSH key generation + age key
    # ---------------------------------------------------------------------------
    generate_ssh_keys() {
      log "Generating SSH host keys for $HOSTNAME..."
      ssh-keygen -t ed25519 -f "$TEMP_DIR/ssh_host_ed25519_key" -N "" -C "root@$HOSTNAME"
      ssh-keygen -t rsa -b 4096 -f "$TEMP_DIR/ssh_host_rsa_key" -N "" -C "root@$HOSTNAME"
      ssh-to-age -private-key -i "$TEMP_DIR/ssh_host_ed25519_key" -o "$TEMP_DIR/age_key.txt"
      PUBLIC_AGE_KEY=$(age-keygen -y "$TEMP_DIR/age_key.txt")
      log "Derived age key : $PUBLIC_AGE_KEY"
    }

    # ---------------------------------------------------------------------------
    # SOPS update
    # ---------------------------------------------------------------------------
    update_sops() {
        local sops_yaml="$FLAKE_DIR/.sops.yaml"

        if [[ -z $PUBLIC_AGE_KEY ]]; then
            error "No public age key available to add to .sops.yaml"
        fi

        if grep -q "&$HOSTNAME " "$sops_yaml"; then
            log "Replacing $HOSTNAME age key in .sops.yaml..."
            sed -i "s/&$HOSTNAME .*/\&$HOSTNAME $PUBLIC_AGE_KEY/" "$sops_yaml"
        else
            log "Adding $HOSTNAME age key to .sops.yaml..."

            local last_def
            last_def=$(grep -n "^  - &" "$sops_yaml" | tail -1 | cut -d: -f1)
            sed -i "''${last_def}a\  - \&$HOSTNAME $PUBLIC_AGE_KEY" "$sops_yaml"

            local last_ref
            last_ref=$(grep -n "^\s*- \*" "$sops_yaml" | tail -1 | cut -d: -f1)
            sed -i "''${last_ref}a\          - *$HOSTNAME" "$sops_yaml"
        fi

        log "Re-encrypting secrets..."
        sops updatekeys "$SECRETS_DIR/secrets.yaml"

        # Commit & push .sops.yaml
        cd "$FLAKE_DIR"
        git add .sops.yaml
        git commit -m "feat(sops): add $HOSTNAME age key to .sops.yaml"

        # Commit & push secrets
        cd "$SECRETS_DIR"
        git add secrets.yaml
        git commit -m "feat(secrets): add $HOSTNAME age key and re-encrypt"
        git push
        cd "$FLAKE_DIR"

        nix flake update secrets
    }

    # ---------------------------------------------------------------------------
    # LUKS password extraction
    # ---------------------------------------------------------------------------
    extract_luks_password() {
      log "Extracting LUKS password..."
      LUKS_PASSWORD_FILE="$TEMP_DIR/luks-password.txt"
      sops -d --extract '["systems"]["luksPassword"]' "$SECRETS_DIR/secrets.yaml" > "$LUKS_PASSWORD_FILE" 2>/dev/null || \
        error "Failed to extract systems.luksPassword"
      chmod 600 "$LUKS_PASSWORD_FILE"
      log "LUKS password extracted"
    }

    # ---------------------------------------------------------------------------
    # Extra files for nixos-anywhere
    # ---------------------------------------------------------------------------
    prepare_extra_files() {
      EXTRA_FILES_DIR="$TEMP_DIR/extra-files"

      install -d -m 755 "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/ssh"
      cp "$TEMP_DIR/ssh_host_ed25519_key"* "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/ssh/"
      [[ -f "$TEMP_DIR/ssh_host_rsa_key" ]] && cp "$TEMP_DIR/ssh_host_rsa_key"* "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/ssh/"

      chmod 600 "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/ssh/ssh_host_"*
      chmod 644 "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/ssh/ssh_host_"*.pub

      install -d -m 755 "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/sops/age"
      cp "$TEMP_DIR/age_key.txt" "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/sops/age/keys.txt"
      chmod 600 "$EXTRA_FILES_DIR/$PERSIST_DIR/etc/sops/age/keys.txt"

      log "Prepared extra files for nixos-anywhere"
    }

    # ---------------------------------------------------------------------------
    # Remove old known_hosts entries
    # ---------------------------------------------------------------------------
    remove_known_host() {
      ssh-keygen -R "$TARGET_DESTINATION" >/dev/null 2>&1 || true
      sed -i "/$HOSTNAME/d" ~/.ssh/known_hosts 2>/dev/null || true
    }

    # ---------------------------------------------------------------------------
    # Run nixos-anywhere installation
    # ---------------------------------------------------------------------------
    run_nixos_anywhere() {
      remove_known_host
      log "Installation summary:"
      echo "  Hostname        : $HOSTNAME"
      echo "  Target          : $TARGET_USER@$TARGET_DESTINATION"
      echo "  SSH port        : $SSH_PORT"
      echo "  Flake           : $FLAKE_DIR#$HOSTNAME"
      echo "  Age key         : $PUBLIC_AGE_KEY"
      echo "  Extra files dir : $EXTRA_FILES_DIR"
      echo "  Persist dir     : ''${PERSIST_DIR:-(none)}"
      echo "  Build on remote : $BUILD_ON_REMOTE"
      echo "  Generate hw cfg : $GENERATE_HW_CONFIG"
      warn "This will COMPLETELY WIPE the target disk!"
      yes_or_no "Continue?" || error "Cancelled"

      local build_flag=()
      [[ "$BUILD_ON_REMOTE" == true ]] && build_flag=(--build-on remote)

      local hw_flag=()
      [[ "$GENERATE_HW_CONFIG" == true ]] && hw_flag=(--generate-hardware-config  nixos-generate-config "$HW_FILE")

      nixos-anywhere \
          --flake "$FLAKE_DIR#$HOSTNAME" \
          --ssh-port "$SSH_PORT" \
          --post-kexec-ssh-port "$SSH_PORT" \
          --disk-encryption-keys /tmp/secret.key "$LUKS_PASSWORD_FILE" \
          --extra-files "$EXTRA_FILES_DIR" \
          "''${hw_flag[@]}" \
          "''${build_flag[@]}" \
          "$TARGET_USER@$TARGET_DESTINATION"
    }

    # ---------------------------------------------------------------------------
    # Post-install copy & rebuild
    # ---------------------------------------------------------------------------
    post_install() {
      warn "Wait until $HOSTNAME has rebooted and is reachable via SSH."
      read -r -p "Press Enter to continue..."

      remove_known_host
      log "Adding new SSH host key to known_hosts..."
      ssh-keyscan -p "$SSH_PORT" "$TARGET_DESTINATION" | grep -v "^#" >> ~/.ssh/known_hosts 2>/dev/null

      $scp_cmd -r "$FLAKE_DIR" "$USERNAME@$TARGET_DESTINATION:/home/$USERNAME/.config/nix-config"
      $ssh_user "nh os switch -- --impure"
      log "Done!"
    }

    # ===========================================================================
    # Main
    # ===========================================================================
    generate_ssh_keys
    yes_or_no "Update .sops.yaml?" && update_sops
    yes_or_no "Generate hardware config?" && GENERATE_HW_CONFIG=true
    yes_or_no "Run installation?" && extract_luks_password && prepare_extra_files && run_nixos_anywhere
    yes_or_no "Copy config and rebuild?" && post_install
    log "All done!"
  '';
}

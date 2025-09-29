{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  inherit (lib.types) listOf str;

  cfg = config.glace.system.impermanence;
in {
  options.glace.system.impermanence = {
    enable = mkBoolOpt false "Whether to enable impermanence with BTRFS root rollback.";

    extraDirectories = lib.mkOption {
      type = listOf str;
      default = [];
      description = "Additional directories to persist beyond the defaults.";
    };

    extraFiles = lib.mkOption {
      type = listOf str;
      default = [];
      description = "Additional files to persist beyond the defaults.";
    };
  };

  config = mkIf cfg.enable {
    # TODO: move these to their relevant modules as appropriate
    environment.persistence."/persist" = {
      directories =
        [
          "/etc/NetworkManager/system-connections"
          "/etc/secureboot"
          "/var/db/sudo"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/var/lib/bluetooth"
        ]
        ++ cfg.extraDirectories;

      files =
        [
          "/etc/machine-id"
          "/etc/ssh/ssh_host_ed25519_key"
          "/etc/ssh/ssh_host_ed25519_key.pub"
          "/etc/ssh/ssh_host_rsa_key"
          "/etc/ssh/ssh_host_rsa_key.pub"
        ]
        ++ cfg.extraFiles;
    };

    boot.initrd.systemd = {
      enable = true; # enable systemd in stage1 boot process so we can do this
      services.rollback = {
        description = "Rollback BTRFS root subvolume to a pristine state";
        wantedBy = ["initrd.target"];
        after = ["systemd-cryptsetup@enc.service"];
        before = ["sysroot.mount"];
        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /tmp

          # We first mount the btrfs root to /tmp
          # so we can manipulate btrfs subvolumes.
          mount -o subvol=/ /dev/mapper/enc /mnt

          # While we're tempted to just delete /root and create
          # a new snapshot from /root-blank, /root is already
          # populated at this point with a number of subvolumes,
          # which makes `btrfs subvolume delete` fail.
          # So, we remove them first.
          #
          # /root contains subvolumes:
          # - /root/var/lib/portables
          # - /root/var/lib/machines
          #
          # I suspect these are related to systemd-nspawn, but
          # since I don't use it I'm not 100% sure.
          # Anyhow, deleting these subvolumes hasn't resulted
          # in any issues so far, except for fairly
          # benign-looking errors from systemd-tmpfiles.

          btrfs subvolume list -o /mnt/root |
            cut -f9 -d' ' |
            while read subvolume; do
              echo "deleting /$subvolume subvolume..."
              btrfs subvolume delete "/mnt/$subvolume"
            done &&
            echo "deleting /root subvolume..." &&
            btrfs subvolume delete /mnt/root
          echo "restoring blank /root subvolume..."
          btrfs subvolume snapshot /mnt/root-blank /mnt/root

          # Once we're done rolling back to a blank snapshot,
          # we can unmount /tmp and continue on the boot process.
          umount /tmp
        '';
      };
    };
  };
}

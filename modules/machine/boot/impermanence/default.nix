{
  inputs,
  self,
  ...
}: {
  flake-file.inputs.impermanence = {
    url = "github:nix-community/impermanence";
    inputs.nixpkgs.follows = "";
    inputs.home-manager.follows = "";
  };

  flake.modules.nixos.impermanence = {
    config,
    lib,
    ...
  }: let
    inherit (lib) flatten optional;

    cfg = config.internal.boot.impermanence;
    isLuks = cfg.luksDevice != null;
    device =
      if isLuks
      then "/dev/mapper/${cfg.luksDevice}"
      else cfg.device;
  in {
    imports = [
      inputs.impermanence.nixosModules.impermanence
      self.modules.nixos.impermanence-options
    ];

    config = {
      assertions = [
        {
          assertion = isLuks || cfg.device != "";
          message = "boot.impermanence: either luksDevice or device must be set.";
        }
      ];

      internal.persistRoot = "/persist";
      internal.boot.impermanence.enabled = true;

      environment.persistence.${config.internal.persistRoot} = {
        directories = flatten [
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          cfg.extraDirectories
        ];
        files = flatten [
          "/etc/machine-id"
          cfg.extraFiles
        ];
      };

      boot.initrd.systemd = {
        enable = true;
        services.rollback = {
          description = "Rollback BTRFS root subvolume to a pristine state";
          wantedBy = ["initrd.target"];
          after = optional isLuks "systemd-cryptsetup@${cfg.luksDevice}.service";
          before = ["sysroot.mount"];
          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";
          script = ''
            mkdir -p /mnt
            mount -o subvol=/ ${device} /mnt

            btrfs subvolume list -o /mnt/root |
              cut -f9 -d' ' |
              while read subvolume; do
                echo "deleting /$subvolume subvolume..."
                btrfs subvolume delete "/mnt/$subvolume"
              done &&
              echo "deleting /root subvolume..." &&
              btrfs subvolume delete /mnt/root

            echo "restoring blank /root subvolume..."
            btrfs subvolume snapshot /mnt/${cfg.blankSnapshot} /mnt/root

            umount /mnt
          '';
        };
      };
    };
  };
}

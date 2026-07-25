{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.impermanence = {
    inputs = {
      home-manager.follows = "";
      nixpkgs.follows = "";
    };

    url = "github:nix-community/impermanence";
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
      boot.initrd.systemd = {
        enable = true;

        services.rollback = {
          after = optional isLuks "systemd-cryptsetup@${cfg.luksDevice}.service";
          before = ["sysroot.mount"];
          description = "Rollback BTRFS root subvolume to a pristine state";

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

          serviceConfig.Type = "oneshot";
          unitConfig.DefaultDependencies = "no";
          wantedBy = ["initrd.target"];
        };
      };

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

      internal = {
        boot.impermanence.enabled = true;
        persistRoot = "/persist";
      };

      assertions = [
        {
          assertion = isLuks || cfg.device != "";
          message = "boot.impermanence: either luksDevice or device must be set.";
        }
      ];
    };
  };
}

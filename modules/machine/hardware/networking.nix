{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.networking = {config, ...}: let
    inherit (lib) mkIf mkMerge mkOption optionals types;
    cfg = config.internal.hardware.networking;
    iwdEnabled = config.networking.networkmanager.wifi.backend == "iwd";
  in {
    options.internal.hardware.networking = {
      avahi.enable = mkOption {
        default = false;
        description = "Enable Avahi for mDNS host resolution on the local network.";
        type = types.bool;
      };

      hosts = mkOption {
        default = {};
        description = "Extra entries merged into networking.hosts.";
        type = types.attrs;
      };
    };

    config = {
      internal.boot.impermanence.extraDirectories = mkMerge [
        [
          "/etc/NetworkManager/system-connections"
          "/var/lib/NetworkManager"
        ]
        (optionals iwdEnabled [
          "/var/lib/iwd"
        ])
      ];

      networking = {
        inherit (cfg) hosts;

        networkmanager = {
          enable = true;
          dhcp = "internal";
          wifi.backend = "iwd";
        };
      };

      # NIC re-init is flaky after sleep; bouncing NM clears it.
      powerManagement.resumeCommands = "systemctl restart NetworkManager";

      services.avahi = mkIf cfg.avahi.enable {
        enable = true;
        nssmdns4 = true;
        nssmdns6 = true;

        publish = {
          enable = true;
          addresses = true;
          domain = true;
          workstation = true;
        };
      };

      users.users = self.lib.forEachNormalUser config (_: {
        extraGroups = ["networkmanager"];
      });
    };
  };
}

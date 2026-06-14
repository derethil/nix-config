{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.networking = {config, ...}: let
    inherit (lib) mkOption mkIf mkForce types;
    cfg = config.internal.hardware.networking;
  in {
    options.internal.hardware.networking = {
      hosts = mkOption {
        type = types.attrs;
        default = {};
        description = "Extra entries merged into networking.hosts.";
      };
      avahi.enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Avahi for mDNS host resolution on the local network.";
      };
    };

    config = {
      networking = {
        inherit (cfg) hosts;
        networkmanager = {
          enable = true;
          dhcp = "internal";
        };
      };

      # Skip waiting for network on boot; saves ~5s.
      systemd.services.NetworkManager-wait-online.enable = mkForce false;

      # NIC re-init is flaky after sleep; bouncing NM clears it.
      powerManagement.resumeCommands = "systemctl restart NetworkManager";

      users.users = self.lib.forEachNormalUser config (_: {
        extraGroups = ["networkmanager"];
      });

      internal.boot.impermanence.extraDirectories = [
        "/etc/NetworkManager/system-connections"
      ];

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
    };
  };
}

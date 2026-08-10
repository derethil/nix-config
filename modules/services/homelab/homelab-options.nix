{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.nixos.homelab-options = {
    key = "homelab-options";

    options.internal.homelab = {
      address = mkOption {
        default = "192.168.8.10";
        description = "LAN IP that homelab DNS records resolve to (feldspar's static address).";
        type = types.str;
      };

      domain = mkOption {
        default = "lumelle.me";
        description = "Base domain homelab services are published under (e.g. recipes.\${domain}).";
        type = types.str;
      };
    };
  };
}

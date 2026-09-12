{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.nixos.homelab-options = {
    key = "homelab-options";

    options.internal.homelab = {
      address = mkOption {
        default = "100.83.177.95";
        description = "IP that homelab DNS records resolve to.";
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

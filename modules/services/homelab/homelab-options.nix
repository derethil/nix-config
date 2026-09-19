{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.nixos.homelab-options = {
    key = "homelab-options";

    options.internal.homelab = {
      addresses = mkOption {
        description = "Non-empty list of IP addresses that homelab DNS records resolve to and Blocky listens on.";
        type = types.addCheck (types.listOf types.str) (addresses: addresses != []);
      };

      domain = mkOption {
        description = "Base domain homelab services are published under (e.g. recipes.\${domain}).";
        type = types.str;
      };
    };
  };
}

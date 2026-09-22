{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
in {
  flake-file.inputs.quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  flake.modules.nixos.quadlet = {config, ...}: {
    key = "quadlet";

    imports = [
      inputs.quadlet-nix.nixosModules.quadlet
      self.modules.nixos.podman
      self.modules.nixos.time
    ];

    options.virtualisation.quadlet.containers = mkOption {
      type = types.attrsOf (types.submodule {
        config.containerConfig = {
          environments.TZ = config.time.timeZone;
          volumes = ["/etc/localtime:/etc/localtime:ro"];
        };
      });
    };

    config.virtualisation.quadlet.enable = true;
  };
}

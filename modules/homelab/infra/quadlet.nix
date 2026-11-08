{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (self.lib.podman) user;

  localtime = ["/etc/localtime:/etc/localtime:ro"];
in {
  flake-file.inputs.quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  flake.modules = {
    nixos.quadlet = {config, ...}: {
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
            volumes = localtime;
          };
        });
      };

      config = {
        home-manager.users.${user} = {
          imports = [self.modules.homeManager.quadlet];
          home.stateVersion = "25.05";
        };

        virtualisation.quadlet.enable = true;
      };
    };

    homeManager.quadlet = {osConfig, ...}: {
      imports = [inputs.quadlet-nix.homeManagerModules.quadlet];

      options.virtualisation.quadlet.containers = mkOption {
        type = types.attrsOf (types.submodule {
          config.containerConfig = {
            environments.TZ = osConfig.time.timeZone;
            volumes = localtime;
          };
        });
      };
    };
  };
}

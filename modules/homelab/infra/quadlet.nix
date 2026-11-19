{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption recursiveUpdate types;
  inherit (self.lib.podman) user;

  localtime = ["/etc/localtime:/etc/localtime:ro"];

  containers = timeZone:
    mkOption {
      type = types.attrsOf (types.submodule {
        config.containerConfig = {
          environments.TZ = timeZone;
          volumes = localtime;
        };
      });
    };
in {
  flake-file.inputs.quadlet-nix.url = "github:SEIAROTg/quadlet-nix";

  flake = {
    modules = {
      nixos.quadlet = {config, ...}: {
        key = "quadlet";

        imports = [
          inputs.quadlet-nix.nixosModules.quadlet
          self.modules.nixos.podman
          self.modules.nixos.time
        ];

        options.virtualisation.quadlet.containers = containers config.time.timeZone;

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
        options.virtualisation.quadlet.containers = containers osConfig.time.timeZone;
      };
    };

    lib.quadlet = {
      mkQuadletPod = port: internalPort: {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      mkQuadletPostgresPod = config: podName: options: let
        inherit (config.virtualisation.quadlet) pods;
      in
        recursiveUpdate {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            noNewPrivileges = true;
            pod = pods.${podName}.ref;
            pull = "newer";
            volumes = ["${podName}-db:/var/lib/postgresql"];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "${podName} postgreSQL database";
        }
        options;
    };
  };
}

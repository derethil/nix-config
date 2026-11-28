{
  self,
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkMerge mkOption recursiveUpdate types;
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

    lib.quadlet = rec {
      mkHealthCheck = cmd: overrides:
        mkMerge [
          {
            healthCmd = cmd;
            healthInterval = "10s";
            healthRetries = 3;
            healthTimeout = "5s";
            notify = "healthy";
          }
          overrides
        ];

      mkQuadletPod = port: internalPort: mkQuadletPod' port internalPort {};

      mkQuadletPod' = port: internalPort: options:
        recursiveUpdate {
          autoStart = true;

          podConfig = {
            exitPolicy = "continue";
            publishPorts = ["127.0.0.1:${port}:${internalPort}"];
          };
        }
        options;

      mkQuadletPostgresPod = config: podName: options: let
        inherit (config.virtualisation.quadlet) pods;
      in
        recursiveUpdate
        {
          containerConfig = mkMerge [
            (mkHealthCheck ''pg_isready -U "$POSTGRES_USER"'' {
              healthStartupCmd = ''pg_isready -U "$POSTGRES_USER"'';
              healthStartupInterval = "5s";
              healthStartupRetries = 60;
            })

            {
              addCapabilities = [
                "CHOWN"
                "DAC_OVERRIDE"
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
            }

            (options.containerConfig or {})
          ];

          serviceConfig.Restart = "always";
          unitConfig.Description = "${podName} postgreSQL database";
        }
        (removeAttrs options ["containerConfig"]);
    };
  };
}

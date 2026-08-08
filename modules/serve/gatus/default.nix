{self, ...}: {
  flake.modules.nixos.gatus = {config, ...}: let
    version = "v5.36.0";
    postgresVersion = "17-alpine";

    subdomain = "health";
    port = "20030";
    internalPort = "8080";

    # TODO:
    # - Configure restic backups to send durations to Gatus along with status and error messages.
    # - Replace internet endpoint with the proper 'connectivity' that turns off checks when it goes red.

    inherit (config.virtualisation.quadlet) pods;
  in {
    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.gatus-config-file
      self.modules.nixos.gatus-endpoints
      self.modules.nixos.ingress
      self.modules.nixos.quadlet
      self.modules.nixos.restic
      self.modules.nixos.secrets
    ];

    internal.homelab = {
      backups.gatus = {
        postgres = [
          {
            container = "gatus-db";
            database = "gatus";
            user = "gatus";
          }
        ];

        restore = {
          startAfter = ["gatus-web.service"];
          startBefore = ["gatus-pod.service" "gatus-db.service"];
          stopServices = ["gatus-web.service" "gatus-db.service" "gatus-pod.service"];
        };
      };

      gatus = {
        inherit internalPort;
      };

      ingress.gatus = {
        inherit port subdomain;
      };
    };

    sops = {
      secrets = {
        "serve/gatus/ntfy_topic".mode = "0444";
        "serve/gatus/postgres_password" = {};
        "serve/gatus/token" = {};
      };

      templates."gatus-env" = {
        mode = "0400";
        content = ''
          POSTGRES_DB=gatus
          POSTGRES_USER=gatus
          POSTGRES_PASSWORD=${config.sops.placeholder."serve/gatus/postgres_password"}
          GATUS_TOKEN=${config.sops.placeholder."serve/gatus/token"}
          NTFY_TOPIC=${config.sops.placeholder."serve/gatus/ntfy_topic"}
        '';
      };
    };

    virtualisation.quadlet = {
      containers = {
        gatus-db = {
          containerConfig = {
            addCapabilities = [
              "CHOWN"
              "DAC_READ_SEARCH"
              "FOWNER"
              "SETGID"
              "SETUID"
            ];

            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."gatus-env".path];
            image = "docker.io/library/postgres:${postgresVersion}";
            noNewPrivileges = true;
            pod = pods.gatus.ref;
            pull = "newer";

            volumes = [
              "gatus-db:/var/lib/postgresql/data"
            ];
          };

          serviceConfig.Restart = "always";
          unitConfig.Description = "Gatus PostgreSQL Database";
        };

        gatus-web = {
          containerConfig = {
            dropCapabilities = ["ALL"];
            environmentFiles = [config.sops.templates."gatus-env".path];
            image = "docker.io/twinproduction/gatus:${version}";
            noNewPrivileges = true;
            pod = pods.gatus.ref;
            pull = "newer";

            volumes = [
              "${config.internal.homelab.gatus.configFile}:/config/config.yaml:ro"
            ];
          };

          serviceConfig.Restart = "always";

          unitConfig = {
            After = ["gatus-db.service"];
            Description = "Gatus Health Dashboard";
            Requires = ["gatus-db.service"];
          };
        };
      };

      pods.gatus = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes.gatus-db = {};
    };

    assertions = [
      {
        assertion = config.internal.homelab.gatus.configFile != null;
        message = "internal.homelab.gatus.configFile must be set to a valid path.";
      }
    ];
  };
}

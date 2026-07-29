{self, ...}: {
  flake.modules.nixos.healthchecks = {config, ...}: let
    version = "4.3";
    subdomain = "status";
    port = "20030";
    internalPort = "8000";
    host = "${subdomain}.${config.internal.homelab.domain}";
  in {
    imports = [
      self.modules.nixos.homelab-routing
      self.modules.nixos.quadlet
      self.modules.nixos.secrets
    ];

    internal.homelab.routing.healthchecks = {
      inherit port subdomain;
    };

    sops = {
      secrets."services/homelab/healthchecks/secret_key" = {};

      templates."healthchecks-env" = {
        mode = "0400";
        content = ''
          SECRET_KEY=${config.sops.placeholder."services/homelab/healthchecks/secret_key"}
        '';
      };
    };

    virtualisation.quadlet = {
      containers.healthchecks = {
        containerConfig = {
          addCapabilities = [
            "CHOWN"
            "SETGID"
            "SETUID"
          ];

          dropCapabilities = ["ALL"];
          environmentFiles = [config.sops.templates."healthchecks-env".path];

          environments = {
            ALLOWED_HOSTS = host;
            DB = "sqlite";
            DB_NAME = "/data/hc.sqlite";
            INTEGRATIONS_ALLOW_PRIVATE_IPS = "True";
            REGISTRATION_OPEN = "False";
            SITE_NAME = "Homelab Status";
            SITE_ROOT = "https://${host}";
          };

          image = "docker.io/healthchecks/healthchecks:v${version}";
          noNewPrivileges = true;
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
          pull = "newer";
          volumes = ["healthchecks-data:/data"];
        };

        serviceConfig.Restart = "always";
        unitConfig.Description = "Healthchecks Monitoring Dashboard";
      };

      volumes.healthchecks-data = {};
    };
  };
}

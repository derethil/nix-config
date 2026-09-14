{self, ...}: {
  flake.modules.nixos.pick-a-recipe = {config, ...}: let
    version = "latest";

    subdomain = "recipes.picker";
    port = "20070";
    internalPort = "5006";
    url = "https://${subdomain}.${config.internal.homelab.domain}";

    inherit (config.virtualisation.quadlet) pods;
    inherit (self.lib.podman) svc volume;
  in {
    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.ingress
      self.modules.nixos.oidc-options
      self.modules.nixos.quadlet
      self.modules.nixos.restic
      self.modules.nixos.secrets
    ];

    internal.homelab = {
      backups.pick-a-recipe = {
        files.paths = map volume ["pick-a-recipe-data"];

        restore.services = {
          afterRestore = map svc ["pick-a-recipe-web"];
          afterSync = map svc ["pick-a-recipe-pod"];
          stop = map svc ["pick-a-recipe-web" "pick-a-recipe-pod"];
        };
      };

      gatus.endpoints.pick-a-recipe = {};

      ingress.pick-a-recipe = {
        inherit port subdomain;
      };
    };

    sops = {
      secrets = {
        "serve/pick_a_recipe/flask_secret_key" = {};
        "serve/pick_a_recipe/oidc/client_id" = {};
        "serve/pick_a_recipe/oidc/client_secret" = {};
      };

      templates."pick-a-recipe-env" = {
        mode = "0400";
        content = ''
          FLASK_SECRET_KEY=${config.sops.placeholder."serve/pick_a_recipe/flask_secret_key"}
          AUTHENTIK_CLIENT_ID=${config.sops.placeholder."serve/pick_a_recipe/oidc/client_id"}
          AUTHENTIK_CLIENT_SECRET=${config.sops.placeholder."serve/pick_a_recipe/oidc/client_secret"}
        '';
      };
    };

    virtualisation.quadlet = {
      containers.pick-a-recipe-web = {
        containerConfig = {
          addCapabilities = [
            "CHOWN"
            "SETGID"
            "SETUID"
          ];

          dropCapabilities = ["ALL"];
          environmentFiles = [config.sops.templates."pick-a-recipe-env".path];

          environments = {
            AUTHENTIK_ADMIN_GROUP = "admins";
            AUTHENTIK_ISSUER_URL = config.internal.homelab.oidc.issuerUrl;
            AUTHENTIK_USER_GROUP = "standard_access";
            AUTH_MODE = "authentik";
            HOST = "0.0.0.0";
            PORT = internalPort;
            PUBLIC_URL = url;
          };

          image = "docker.io/pickeld/pick-a-recipe:${version}";
          noNewPrivileges = true;
          pod = pods.pick-a-recipe.ref;
          pull = "newer";
          volumes = ["pick-a-recipe-data:/app/data"];
        };

        serviceConfig.Restart = "always";
        unitConfig.Description = "Pick-a-Recipe AI Recipe Importer";
      };

      pods.pick-a-recipe = {
        autoStart = true;

        podConfig = {
          exitPolicy = "continue";
          publishPorts = ["127.0.0.1:${port}:${internalPort}"];
        };
      };

      volumes.pick-a-recipe-data = {};
    };
  };
}

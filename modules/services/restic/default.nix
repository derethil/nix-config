{self, ...}: {
  flake.modules.nixos.restic = {config, ...}: let
    cacheDir = "/var/lib/restic/cache";
    gatusDomain = self.lib.homelab.mkServiceDomain config "gatus";
  in {
    key = "restic";

    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.restic-backup
      self.modules.nixos.restic-maintenance
      self.modules.nixos.restic-options
      self.modules.nixos.restic-restore
      self.modules.nixos.secrets
      self.modules.nixos.impermanence-options
    ];

    config = {
      internal.boot.impermanence.extraDirectories = ["/var/lib/restic"];

      sops = {
        secrets = {
          "serve/gatus/token" = {};
          "services/restic/b2_account_id" = {};
          "services/restic/b2_account_key" = {};
          "services/restic/repository" = {};
          "services/restic/repository_password" = {};
        };

        templates."restic-env".content = ''
          B2_ACCOUNT_ID=${config.sops.placeholder."services/restic/b2_account_id"}
          B2_ACCOUNT_KEY=${config.sops.placeholder."services/restic/b2_account_key"}
          GATUS_URL=${gatusDomain}
          GATUS_TOKEN=${config.sops.placeholder."serve/gatus/token"}
          RESTIC_CACHE_DIR=${cacheDir}
        '';
      };
    };
  };
}

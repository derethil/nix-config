{
  self,
  lib,
  ...
}: {
  flake.modules.nixos.restic = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) optionalString;

    cacheDir = "/var/lib/restic/cache";
    gatusUrl = config.internal.homelab.gatus.pushUrl;
  in {
    key = "restic";

    imports = [
      self.modules.nixos.gatus-options
      self.modules.nixos.ingress-options
      self.modules.nixos.restic-backup
      self.modules.nixos.restic-maintenance
      self.modules.nixos.restic-options
      self.modules.nixos.restic-restore
      self.modules.nixos.secrets
      self.modules.nixos.impermanence-options
    ];

    config = {
      environment.systemPackages = [pkgs.restic pkgs.backblaze-b2];
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
          ${optionalString (gatusUrl != null) "GATUS_URL=${gatusUrl}"}
          GATUS_TOKEN=${config.sops.placeholder."serve/gatus/token"}
          RESTIC_CACHE_DIR=${cacheDir}
        '';
      };
    };
  };
}

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
    inherit (lib) concatMapStringsSep flatten getExe' mapAttrs;

    cfg = config.internal.homelab.backups;
    healthChecksDomain = self.lib.homelab.mkServiceDomain config "healthchecks";

    stagingRoot = "/var/lib/restic/staging";
    cacheDir = "/var/lib/restic/cache";

    curl = getExe' pkgs.curl "curl";
    podman = getExe' pkgs.podman "podman";

    stagingDir = name: "${stagingRoot}/${name}";
    dumpFile = name: pg: "${stagingDir name}/${pg.container}-${pg.database}.dump";

    dumpCommands = name: job:
      concatMapStringsSep "\n"
      (pg: ''${podman} exec ${pg.container} pg_dump -U ${pg.user} -Fc ${pg.database} > ${dumpFile name pg}'')
      job.postgres;

    prepareScript = name: job:
      pkgs.writeShellScript "restic-prepare-${name}-backup" ''
        set -euo pipefail
        mkdir -p ${stagingDir name}
        ${job.prepareCommand}
        ${dumpCommands name job}
        ${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/${name}-backup/start?create=1" || true
      '';

    pingStop = name:
      pkgs.writeShellScript "restic-ping-${name}" ''
        if [ "$EXIT_STATUS" = "0" ]; then
          ${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/${name}-backup?create=1" || true
        else
          ${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/${name}-backup/fail?create=1" || true
        fi
      '';
  in {
    key = "restic";

    imports = [
      self.modules.nixos.restic-options
      self.modules.nixos.secrets
      self.modules.nixos.postgresql
    ];

    config = {
      environment.systemPackages = [
        pkgs.restic
        pkgs.backblaze-b2
      ];

      internal.boot.impermanence.extraDirectories = ["/var/lib/restic"];

      services.restic.backups =
        mapAttrs (
          name: job: {
            inherit (job) exclude;
            backupCleanupCommand = "${pingStop name}";
            backupPrepareCommand = "${prepareScript name job}";
            checkOpts = ["--retry-lock" job.retryLock "--read-data-subset=5%"];
            environmentFile = config.sops.templates."restic-env".path;
            extraBackupArgs = ["--retry-lock" job.retryLock];
            initialize = true;
            passwordFile = config.sops.secrets."services/homelab/restic/repository_password".path;

            paths = flatten [
              (map (pg: dumpFile name pg) job.postgres)
              job.paths
            ];

            pruneOpts = [
              "--retry-lock ${job.retryLock}"
              "--keep-daily 7"
              "--keep-monthly 6"
              "--keep-weekly 4"
            ];

            repositoryFile = config.sops.secrets."services/homelab/restic/repository".path;

            timerConfig = {
              OnCalendar = job.onCalendar;
              Persistent = true;
              RandomizedDelaySec = "15m";
            };
          }
        )
        cfg;

      sops = {
        secrets = {
          "services/homelab/restic/b2_account_id" = {};
          "services/homelab/restic/b2_account_key" = {};
          "services/homelab/restic/healthchecks_ping_key" = {};
          "services/homelab/restic/repository" = {};
          "services/homelab/restic/repository_password" = {};
        };

        templates."restic-env".content = ''
          B2_ACCOUNT_ID=${config.sops.placeholder."services/homelab/restic/b2_account_id"}
          B2_ACCOUNT_KEY=${config.sops.placeholder."services/homelab/restic/b2_account_key"}
          HC_PING_URL=${healthChecksDomain}/ping/${config.sops.placeholder."services/homelab/restic/healthchecks_ping_key"}
          RESTIC_CACHE_DIR=${cacheDir}
        '';
      };
    };
  };
}

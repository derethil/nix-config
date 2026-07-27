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

    stagingRoot = "/var/lib/restic/staging";
    cacheDir = "/var/lib/restic/cache";

    curl = getExe' pkgs.curl "curl";
    podman = getExe' pkgs.podman "podman";
    pg_dump = getExe' pkgs.postgresql_17 "pg_dump";

    stagingDir = name: "${stagingRoot}/${name}";
    dumpFile = name: pg: "${stagingDir name}/${pg.container}-${pg.database}.dump";

    dumpCommands = name: job:
      concatMapStringsSep "\n"
      (pg: ''${podman} exec ${pg.container} ${pg_dump} -U ${pg.user} -Fc ${pg.database} > ${dumpFile name pg}'')
      job.postgres;

    prepareScript = name: job:
      pkgs.writeShellScript "restic-prepare-${name}" ''
        set -euo pipefail
        mkdir -p ${stagingDir name}
        ${job.prepareCommand}
        ${dumpCommands name job}
        ${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/${name}/start?create=1" || true
      '';

    pingStop = name:
      pkgs.writeShellScript "restic-ping-${name}" ''
        if [ "$EXIT_STATUS" = "0" ]; then
          ${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/${name}?create=1" || true
        else
          ${curl} -fsS -m 10 --retry 3 "$HC_PING_URL/${name}/fail?create=1" || true
        fi
      '';
  in {
    key = "restic";

    imports = [
      self.modules.nixos.restic-options
      self.modules.nixos.secrets
    ];

    config = {
      internal.boot.impermanence.extraDirectories = ["/var/lib/restic"];

      services.restic.backups =
        mapAttrs (
          name: job: {
            inherit (job) exclude;
            backupCleanupCommand = "${pingStop name}";
            backupPrepareCommand = "${prepareScript name job}";
            checkOpts = ["--read-data-subset=5%"];
            environmentFile = config.sops.templates."restic-env".path;
            initialize = true;
            passwordFile = config.sops.secrets."services/homelab/restic/repository_password".path;

            paths = flatten [
              (map (pg: dumpFile name pg) job.postgres)
              job.paths
            ];

            pruneOpts = [
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
          "services/homelab/restic/hc_ping_url" = {};
          "services/homelab/restic/repository" = {};
          "services/homelab/restic/repository_password" = {};
        };

        templates."restic-env".content = ''
          B2_ACCOUNT_ID=${config.sops.placeholder."services/homelab/restic/b2_account_id"}
          B2_ACCOUNT_KEY=${config.sops.placeholder."services/homelab/restic/b2_account_key"}
          HC_PING_URL=${config.sops.placeholder."services/homelab/restic/hc_ping_url"}
          RESTIC_CACHE_DIR=${cacheDir}
        '';
      };
    };
  };
}

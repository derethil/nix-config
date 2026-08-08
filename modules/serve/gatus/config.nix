{self, ...}: {
  flake.modules.nixos.gatus-config-file = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) assertMsg filterAttrs mapAttrsToList toInt;

    cfg = config.internal.homelab.gatus;
    inherit (cfg) internalPort;

    ntfyAlert = [{type = "ntfy";}];

    resolveUrl = name: endpoint:
      if endpoint.url != null
      then endpoint.url
      else
        assert assertMsg (config.internal.homelab.ingress ? ${name})
        "gatus.endpoints.${name}: set `url`, or add an ingress service named `${name}` to derive it from"; "${self.lib.homelab.mkServiceDomain config name}${endpoint.path}";
  in {
    config.internal.homelab.gatus.configFile = (pkgs.formats.yaml {}).generate "gatus.yaml" {
      alerting.ntfy = {
        click = self.lib.homelab.mkServiceDomain config "gatus";

        default-alert = {
          failure-threshold = 3;
          send-on-resolved = true;
        };

        priority = 4;
        topic = "\${NTFY_TOPIC}";
      };

      connectivity.checker = {
        interval = "60s";
        target = "1.1.1.1:53";
      };

      endpoints =
        mapAttrsToList (
          name: endpoint:
            filterAttrs (_: v: v != null) {
              inherit (endpoint) conditions dns group interval name;
              alerts = ntfyAlert;
              url = resolveUrl name endpoint;
            }
        )
        cfg.endpoints;

      external-endpoints =
        mapAttrsToList (_: endpoint: {
          inherit (endpoint) group name;
          alerts = ntfyAlert;
          heartbeat.interval = endpoint.heartbeatInterval;
          token = "\${GATUS_TOKEN}";
        })
        cfg.externalEndpoints;

      storage = {
        path = "postgres://gatus:\${POSTGRES_PASSWORD}@localhost:5432/gatus?sslmode=disable";
        type = "postgres";
      };

      ui.default-sort-by = "group";
      web.port = toInt internalPort;
    };
  };
}

{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake.modules.nixos.gatus-options = {
    key = "gatus-options";

    options.internal.homelab.gatus = {
      configFile = mkOption {
        default = null;
        description = "Path to the Gatus config file.";
        type = types.nullOr types.path;
      };

      endpoints = mkOption {
        default = {};
        description = "Gatus endpoints (pull-based blackbox monitoring); services register their own health probes.";

        type = types.attrsOf (types.submodule ({name, ...}: {
          options = {
            conditions = mkOption {
              default = ["[STATUS] < 400" "[CERTIFICATE_EXPIRATION] > 168h"];
              description = "Gatus conditions the probe response must satisfy to be healthy.";
              type = types.listOf types.str;
            };

            dns = mkOption {
              default = null;
              description = "DNS query settings; when set, turns this into a DNS-type check (url becomes the resolver to query).";

              type = types.nullOr (types.submodule {
                options = {
                  query-name = mkOption {
                    description = "Name to resolve.";
                    type = types.str;
                  };

                  query-type = mkOption {
                    default = "A";
                    description = "DNS record type to query.";
                    type = types.str;
                  };
                };
              });
            };

            group = mkOption {
              default = "applications";
              description = "Dashboard group the endpoint is displayed under.";
              type = types.str;
            };

            interval = mkOption {
              default = "1m";
              description = "How often Gatus probes the endpoint.";
              type = types.str;
            };

            name = mkOption {
              default = name;
              description = "Endpoint name (defaults to the attribute name).";
              type = types.str;
            };

            path = mkOption {
              default = "";
              description = "Path appended to the derived ingress URL. Ignored when url is set explicitly.";
              type = types.str;
            };

            url = mkOption {
              default = null;
              description = "Full URL to probe. Defaults to the https host of the ingress service with the same name.";
              type = types.nullOr types.str;
            };
          };
        }));
      };

      externalEndpoints = mkOption {
        default = {};
        description = "Gatus external (push-based) endpoints; features register their own heartbeat monitors.";

        type = types.attrsOf (types.submodule ({name, ...}: {
          options = {
            group = mkOption {
              default = "";
              description = "Dashboard group the endpoint is displayed under.";
              type = types.str;
            };

            heartbeatInterval = mkOption {
              description = "Marks the endpoint unhealthy if no push arrives within this interval.";
              type = types.str;
            };

            name = mkOption {
              default = name;
              description = "Endpoint name (defaults to the attribute name).";
              type = types.str;
            };
          };
        }));
      };

      internalPort = mkOption {
        default = "8080";
        description = "Gatus internal port (loopback, not exposed to the LAN).";
        type = types.str;
      };

      pushUrl = mkOption {
        default = null;
        description = "Base URL for pushing external-endpoint heartbeats (gatus-cli push --url). Populated by the gatus service module; null when gatus isn't deployed, in which case features skip their heartbeat pushes.";
        type = types.nullOr types.str;
      };
    };
  };
}

{lib, ...}: let
  inherit (lib) mkOption types;
in {
  flake = {
    modules.nixos.oidc-options = {
      key = "oidc-options";

      options.internal.homelab.oidc = mkOption {
        default = null;
        description = "OIDC provider endpoints, populated by the identity provider module and consumed by relying modules.";

        type = types.nullOr (types.submodule {
          options = {
            discoveryUrl = mkOption {
              description = "OIDC discovery document URL (.well-known/openid-configuration).";
              type = types.str;
            };

            endSessionUrl = mkOption {
              description = "RP-initiated logout (end_session) endpoint.";
              type = types.str;
            };

            issuerUrl = mkOption {
              description = "OIDC issuer / base URL.";
              type = types.str;
            };

            name = mkOption {
              description = "Human-readable provider name shown on login buttons.";
              type = types.str;
            };

            providerId = mkOption {
              description = "Stable provider slug relying parties key off (e.g. django-allauth provider_id, used in /accounts/oidc/<providerId>/ URLs).";
              type = types.str;
            };
          };
        });
      };
    };

    # Helper functions to construct OIDC provider configuration
    lib.oidc.allauthProvider = {
      clientId,
      clientSecret,
      discoveryUrl,
      name,
      providerId,
    }:
      builtins.toJSON {
        openid_connect.APPS = [
          {
            inherit name;
            client_id = clientId;
            provider_id = providerId;
            secret = clientSecret;
            settings.server_url = discoveryUrl;
          }
        ];
      };
  };
}

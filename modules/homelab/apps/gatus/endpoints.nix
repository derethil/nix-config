{
  flake.modules.nixos.gatus-endpoints = {config, ...}: {
    config.internal.homelab.gatus.endpoints.domain-expiration = {
      conditions = ["[DOMAIN_EXPIRATION] > 720h"];
      group = "infrastructure";
      interval = "1h";
      url = "https://${config.internal.homelab.domain}";
    };
  };
}

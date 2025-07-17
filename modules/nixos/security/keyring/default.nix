{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.security.keyring;
in {
  options.security.keyring = {
    enable = mkBoolOpt false "Whether to enable the Keyring service.";
  };

  config = mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
  };
}

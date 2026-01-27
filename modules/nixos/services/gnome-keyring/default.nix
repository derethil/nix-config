{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.services.gnome-keyring;
in {
  options.glace.services.gnome-keyring = {
    enable = mkBoolOpt false "Whether to enable GNOME Keyring service at system level.";
  };

  config = mkIf cfg.enable {
    services.gnome.gnome-keyring.enable = true;
  };
}

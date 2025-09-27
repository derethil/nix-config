{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.desktop.display-managers.tuigreet;
in {
  options.desktop.display-managers.tuigreet = {
    enable = mkBoolOpt false "Whether to enable greetd with tuigreet.";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      settings = {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --cmd uwsm start";
          user = "greeter";
        };
      };
    };
  };
}


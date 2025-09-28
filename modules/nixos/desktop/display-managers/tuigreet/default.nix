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
      useTextGreeter = true;
      settings = rec {
        default_session = {
          command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
          user = "greeter";
        };
        initial_session = default_session;
      };
    };

    # Fix greeter user/group to prevent dbus reload issues
    users.users.greeter = {
      isSystemUser = true;
      group = "greeter";
      uid = 995;
    };
    users.groups.greeter = {
      gid = 993;
    };
  };
}

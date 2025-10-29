{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.display-managers.tuigreet;
in {
  options.glace.desktop.display-managers.tuigreet = {
    enable = mkBoolOpt false "Whether to enable greetd with tuigreet.";
  };

  config = mkIf cfg.enable {
    services.greetd = {
      enable = true;
      # TODO: Not on stable yet
      # useTextGreeter = true;
      settings = {
        default_session = {
          command = "${getExe pkgs.unstable.tuigreet} --time --remember --remember-session";
          user = "greeter";
        };
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

    glace.system.impermanence.extraDirectories = ["/var/cache/tuigreet"];
  };
}

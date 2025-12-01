{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkSubmoduleAttrs mkRequiredOpt;

  cfg = config.glace.desktop.displayManagers.sessions;

  mkSessionPackage = args:
    pkgs.writeTextFile {
      inherit (args) name;
      text = ''
        [Desktop Entry]
        Name=${args.desktopName}
        Comment=${args.comment}
        Exec=${args.exec}
        Type=Application
      '';
      destination =
        if args.wayland
        then "/share/wayland-sessions/${args.name}.desktop"
        else "/share/xsessions/${args.name}.desktop";
      derivationArgs = {
        passthru.providedSessions = [args.name];
      };
    };
in {
  options.glace.desktop.displayManagers.sessions = with types; {
    enable = mkBoolOpt false "Whether to set desktop sessions for display managers.";
    sessionPackages = mkSubmoduleAttrs "Desktop session packages to create." {
      desktopName = mkRequiredOpt str "Pretty name of the session.";
      comment = mkRequiredOpt str "Comment for the session.";
      exec = mkRequiredOpt str "Executable command for the session.";
      wayland = mkBoolOpt true "Whether this is a Wayland session.";
    };
  };

  config = mkIf cfg.enable {
    services.displayManager = {
      enable = true;
      sessionPackages =
        lib.mapAttrsToList (
          name: value:
            mkSessionPackage {
              inherit name;
              inherit
                (value)
                desktopName
                comment
                exec
                wayland
                ;
            }
        )
        cfg.sessionPackages;
    };
  };
}

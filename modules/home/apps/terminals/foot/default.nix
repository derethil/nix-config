{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe getExe';
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.terminals.foot;
  terminalsCfg = config.glace.apps.terminals;
  monoFont = config.glace.system.fonts.default.monospace;
in {
  options.glace.apps.terminals.foot = {
    enable = mkBoolOpt false "Whether to enable the Foot terminal.";
  };

  config = mkIf cfg.enable {
    glace.apps.terminals = {
      desktopFiles.foot = "foot.desktop";
      commands = mkIf (terminalsCfg.default == "foot") {
        base = ["${getExe' pkgs.foot "footclient"}"];
        withTmux = ["${getExe' pkgs.foot "footclient"}" "${getExe pkgs.tmux}" "new-session" "-As" "base"];
      };
    };

    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = "${monoFont.name}:weight=${monoFont.style}:size=${toString monoFont.size}";
          pad = "6x6";
          selection-target = "both";
        };
        colors = {
          alpha = 1.0;
          foreground = "d4be98";
          background = "282828";
          selection-foreground = "3c3836";
          selection-background = "d4be98";
          regular0 = "1d2021";
          regular1 = "ea6962";
          regular2 = "a9b665";
          regular3 = "d8a657";
          regular4 = "7daea3";
          regular5 = "d3869b";
          regular6 = "89b482";
          regular7 = "d4be98";
          bright0 = "eddeb5";
          bright1 = "ea6962";
          bright2 = "a9b665";
          bright3 = "d8a657";
          bright4 = "7daea3";
          bright5 = "d3869b";
          bright6 = "89b482";
          bright7 = "d4be98";
        };
        mouse.hide-when-typing = "yes";
        desktop-notifications.inhibit-when-focused = "no";
      };
    };
  };
}

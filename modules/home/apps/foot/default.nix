{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.foot;
in {
  options.apps.foot = {
    enable = mkBoolOpt false "Whether to enable the Foot terminal.";
  };

  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      server.enable = true;
      settings = {
        main = {
          font = "GeistMono NF SemiBold:size=12";
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

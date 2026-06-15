{self, ...}: {
  flake.modules.homeManager.foot = {
    pkgs,
    lib,
    config,
    ...
  }: let
    inherit (lib) mkOrder mkOverride mkIf;
    priority = 100;
  in {
    imports = [self.modules.homeManager.terminal-options];

    config = mkIf pkgs.stdenv.hostPlatform.isLinux {
      terminal = {
        desktopFiles = mkOrder priority ["foot.desktop"];
        commands = {
          base = mkOverride priority ["footclient"];
          withTmux = mkOverride priority ["footclient" "tmux" "new-session" "-As" "base"];
        };
      };

      programs.foot = {
        enable = true;
        server.enable = true;
        package = pkgs.foot.overrideAttrs (old: {
          postInstall =
            (old.postInstall or "")
            + ''
              echo "TerminalArgAppId=-a" >> $out/share/applications/foot.desktop
            '';
        });
        settings = {
          main = {
            font = "${config.font.monospace.name}:weight=${config.font.monospace.style}:size=${toString config.font.monospace.size}";
            pad = "6x6";
            selection-target = "both";
          };
          colors-dark = {
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
          mouse.hide-when-typing = "no";
          desktop-notifications.inhibit-when-focused = "no";
        };
      };
    };
  };
}

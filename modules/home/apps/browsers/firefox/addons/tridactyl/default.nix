{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.apps.browsers.firefox;
  cfg-lw = config.glace.apps.browsers.librewolf;
in {
  config = mkIf (cfg.enable || cfg-lw.enable) {
    xdg.configFile."tridactyl/tridactylrc".text = ''
      set theme midnight

      bind <d tabclosealltoleft
      bind >d tabclosealltoright

      bind K tabprev
      bind J tabnext
    '';
  };
}

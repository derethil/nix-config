{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.glace.apps.firefox;
in {
  config = mkIf cfg.enable {
    xdg.configFile."tridactyl/tridactylrc".text = ''
      set theme midnight

      bind <d tabclosealltoleft
      bind >d tabclosealltoright

      bind K tabprev
      bind J tabnext
    '';
  };
}

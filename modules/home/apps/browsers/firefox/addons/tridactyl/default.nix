{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.apps.browsers.firefox;
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

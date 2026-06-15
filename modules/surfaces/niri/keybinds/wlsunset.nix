{self, ...}: {
  flake.modules.homeManager.niri-wlsunset = {...}: let
    inherit (self.lib.niri) mkKeybinds;
  in {
    imports = [self.modules.homeManager.wlsunset];

    wayland.windowManager.niri.settings.binds."Mod+Shift+N" = mkKeybinds {hotkey-overlay-title = "Toggle Night Light";} {
      spawn-sh = ["systemctl --user is-active wlsunset.service && systemctl --user stop wlsunset.service || systemctl --user start wlsunset.service"];
    };
  };
}

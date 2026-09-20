{self, ...}: {
  flake.modules.homeManager.niri-wlsunset = let
    inherit (self.lib.niri) mkCategorizedKeybinds mkKeybinds;
  in {
    imports = [self.modules.homeManager.wlsunset];

    wayland.windowManager.niri.settings.binds._children = mkCategorizedKeybinds "Display" {
      "Mod+Shift+N" = mkKeybinds {hotkey-overlay-title = "Toggle Nightshift";} {
        spawn-sh = ["systemctl --user is-active wlsunset.service && systemctl --user stop wlsunset.service || systemctl --user start wlsunset.service"];
      };
    };
  };
}

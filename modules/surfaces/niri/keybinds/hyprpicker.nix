{self, ...}: {
  flake.modules.homeManager.niri-hyprpicker = let
    inherit (self.lib.niri) mkCategorizedKeybinds mkKeybinds;
  in {
    imports = [self.modules.homeManager.hyprpicker];

    wayland.windowManager.niri.settings.binds._children = mkCategorizedKeybinds "Tools" {
      "Mod+B" = mkKeybinds {hotkey-overlay-title = "Pick Color";} {spawn-sh = ["hyprpicker -a"];};
    };
  };
}

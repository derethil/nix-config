{self, ...}: {
  flake.modules.homeManager.niri-hyprpicker = let
    inherit (self.lib.niri) mkKeybinds;
  in {
    imports = [self.modules.homeManager.hyprpicker];

    wayland.windowManager.niri.settings.binds."Mod+B" =
      mkKeybinds {hotkey-overlay-title = "Pick Color";} {spawn-sh = ["hyprpicker -a"];};
  };
}

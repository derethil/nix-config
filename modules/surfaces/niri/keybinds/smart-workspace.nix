{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.niri-smart-workspace = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:derethil/niri-smart-workspace";
  };

  flake.modules.homeManager.niri-smart-workspace = {
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) getExe;
    inherit (self.lib.niri) mkCategorizedKeybinds mkKeybinds;

    smart-workspace = getExe pkgs.inputs.niri-smart-workspace.default;
  in {
    imports = [
      inputs.niri-smart-workspace.homeManagerModules.default
    ];

    services.niri-smart-workspace.enable = true;

    wayland.windowManager.niri.settings.binds._children = mkCategorizedKeybinds "Workspaces" {
      "Mod+BracketLeft" = mkKeybinds {hotkey-overlay-title = "Previous Workspace";} {spawn-sh = "${smart-workspace} up";};
      "Mod+BracketRight" = mkKeybinds {hotkey-overlay-title = "Next Workspace";} {spawn-sh = "${smart-workspace} down";};
      "Mod+WheelScrollDown" = mkKeybinds {hotkey-overlay-title = "Next Workspace";} {spawn-sh = "${smart-workspace} down";};
      "Mod+WheelScrollUp" = mkKeybinds {hotkey-overlay-title = "Previous Workspace";} {spawn-sh = "${smart-workspace} up";};
    };
  };
}

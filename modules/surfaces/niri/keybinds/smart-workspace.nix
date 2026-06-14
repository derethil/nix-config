{inputs, ...}: {
  flake-file.inputs.niri-smart-workspace = {
    url = "github:derethil/niri-smart-workspace";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.niri-smart-workspace = {
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) getExe mkOverride;

    smart-workspace = getExe pkgs.inputs.niri-smart-workspace.default;
    priority = 200;
  in {
    imports = [
      inputs.niri-smart-workspace.homeManagerModules.default
    ];

    services.niri-smart-workspace.enable = true;

    wayland.windowManager.niri.settings.binds = {
      "Mod+BracketLeft" = mkOverride priority {spawn-sh = "${smart-workspace} up";};
      "Mod+BracketRight" = mkOverride priority {spawn-sh = "${smart-workspace} down";};
      "Mod+WheelScrollUp" = mkOverride priority {spawn-sh = "${smart-workspace} up";};
      "Mod+WheelScrollDown" = mkOverride priority {spawn-sh = "${smart-workspace} down";};
    };
  };
}

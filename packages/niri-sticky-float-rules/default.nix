{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule {
  pname = "niri-sticky-float-rules";
  version = "0.1.0";

  src = ./.;

  vendorHash = null; # No external dependencies

  meta = {
    description = "Sticky window rules for niri compositor";
    mainProgram = "niri-sticky-float-rules";
    platforms = lib.platforms.linux;
  };
}

{inputs, ...}: {
  flake.modules.darwin.paneru = {pkgs, ...}: {
    services.paneru.package = inputs.paneru.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
      patches = (old.patches or []) ++ [./patches/reshuffle-on-hover.patch];
    });
  };
}

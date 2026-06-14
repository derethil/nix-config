{self, ...}: {
  # Bridge: expose every per-system package under `pkgs.internal.<name>` so
  # custom packages are clearly distinguishable from upstream nixpkgs.
  flake.overlays.internal-packages = final: _prev: {
    internal = self.packages.${final.stdenv.hostPlatform.system} or {};
  };
}

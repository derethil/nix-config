{lib, ...}: {
  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
    description = ''
      Factory aspect functions. Each factory takes parameters and returns
      a `flake.modules`-shaped attrset, allowing parametric module
      generation. Used via `(self.factory.<name> { ... })` merged into
      `flake.modules`.
    '';
  };
}

{lib, ...}: {
  # Declare `flake.lib` as a freeform attrset so multiple modules can contribute
  # their own helpers (mergeStrict, mkMimeApps, etc.) without conflicting.
  options.flake.lib = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = {};
  };
}

{lib, ...}: let
  mergeStrict' = a: b: collisionType: let
    overlap = builtins.intersectAttrs a b;
  in
    if overlap == {}
    then a // b
    else throw "${collisionType} collision: ${toString (builtins.attrNames overlap)}";
in {
  flake.lib = {
    mergeStrict' = mergeStrict';
    mergeStrict = a: b: mergeStrict' a b "attribute";
    mergeModules = a: b: mergeStrict' a b "module name";

    # True if any package in `packages` matches `pname`.
    # Uses lib.getName, which prefers pname and falls back to stripping the
    # version off name — so derivations like "easyeffects-7.2.0" match cleanly
    # and overrides/wraps (which preserve pname) still work.
    hasPackage = packages: pname:
      lib.any (p: lib.getName p == pname) packages;
  };
}

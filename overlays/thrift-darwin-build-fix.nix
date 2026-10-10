{
  # https://github.com/NixOS/nixpkgs/issues/571774
  flake.overlays.thrift-darwin-build-fix = final: prev: {
    thrift = prev.thrift.overrideAttrs (old:
      final.lib.optionalAttrs final.stdenv.hostPlatform.isDarwin {
        cmakeFlags = old.cmakeFlags ++ [(final.lib.cmakeBool "BUILD_TESTING" false)];
      });
  };
}

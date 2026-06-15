{inputs, ...}: {
  flake-file.inputs.nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

  flake.overlays.unstable = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        allowDeprecatedx86_64Darwin = true;
      };
    };
  };
}

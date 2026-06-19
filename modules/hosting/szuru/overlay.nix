# Temporarily pulls szurubooru from the PR branch that fixes the
# sa.events.event / sqlalchemy 1.3 conflict. Remove once
# https://github.com/NixOS/nixpkgs/pull/532402 lands in nixpkgs.
{inputs, ...}: {
  flake-file.inputs.nixpkgs-szurubooru-pr.url = "github:RatCornu/nixpkgs/szurubooru";

  flake.overlays.szurubooru = final: _prev: let
    szuruPkgs = import inputs.nixpkgs-szurubooru-pr {
      inherit (final.stdenv.hostPlatform) system;
    };
  in {
    szurubooru = szuruPkgs.szurubooru;
  };
}

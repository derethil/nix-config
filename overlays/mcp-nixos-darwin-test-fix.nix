{lib, ...}: {
  # test_read_text_file picks a random file out of the sandbox's /nix/store and
  # fails if its content happens to contain "Error" - flaky on Darwin, already
  # excluded upstream but not yet backported to nixos-26.05.
  # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/by-name/mc/mcp-nixos/package.nix
  flake.overlays.mcp-nixos-darwin-test-fix = _: prev: {
    mcp-nixos = prev.mcp-nixos.overridePythonAttrs (old: {
      disabledTests = lib.flatten [
        old.disabledTests or []
        (lib.optionals prev.stdenv.hostPlatform.isDarwin [
          "test_read_text_file"
        ])
      ];
    });
  };
}

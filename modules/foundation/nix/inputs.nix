{
  inputs,
  lib,
  ...
}: let
  inherit (lib) filterAttrs mapAttrs';

  flakes = filterAttrs (_: v: v ? outputs) inputs;
  registry = builtins.mapAttrs (_: flake: {inherit flake;}) flakes;

  system-module = {
    # Make every flake input available via the nix registry, so things
    # like `nix run nixpkgs#hello` resolve to the pinned versions
    # rather than fetching latest.
    nix.registry = registry;

    # Symlink each input under /etc/nix/inputs so shell tools and
    # NIX_PATH can reach them by name.
    environment.etc =
      mapAttrs' (name: value: {
        name = "nix/inputs/${name}";
        value = {source = value.outPath;};
      })
      inputs;

    # NIX_PATH points at the linked inputs (lets `<nixpkgs>` etc. resolve
    # to the pinned input rather than the system channel).
    nix.nixPath = ["/etc/nix/inputs"];
  };
in {
  flake.modules = {
    nixos.nix-inputs = {
      imports = [system-module];
    };

    darwin.nix-inputs = {
      imports = [system-module];
    };

    homeManager.nix-inputs = {
      nix.registry = registry;
    };
  };
}

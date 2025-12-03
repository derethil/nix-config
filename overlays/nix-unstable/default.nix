{
  channels,
  nixpkgs-unstable,
  ...
}: final: prev: {
  unstable = import nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };
}


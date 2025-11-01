{
  channels,
  nixpkgs-unstable,
  ...
}: final: prev: {
  unstable = nixpkgs-unstable.legacyPackages.${prev.system};
}
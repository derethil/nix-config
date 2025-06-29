{
  channels,
  nixpkgs-stable,
  ...
}: final: prev: {
  stable = nixpkgs-stable.legacyPackages.${prev.system};
}

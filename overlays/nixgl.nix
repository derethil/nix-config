{
  inputs,
  system,
  ...
}: {
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [inputs.nixgl.overlay];
  };
}

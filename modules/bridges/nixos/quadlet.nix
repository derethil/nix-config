{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    quadlet-nix.url = "github:SEIAROTg/quadlet-nix";
  };

  flake.modules.nixos.quadlet = {
    key = "quadlet";

    imports = [
      inputs.quadlet-nix.nixosModules.guadlet
      self.modules.nixos.podman
    ];

    virtualisation.quadlet = {
      enable = true;
    };
  };
}

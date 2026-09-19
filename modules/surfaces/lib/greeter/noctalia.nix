{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.noctalia-greeter = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:noctalia-dev/noctalia-greeter";
  };

  flake.modules.nixos.noctalia-greeter = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
      self.modules.nixos.primary-user
    ];

    internal.boot.impermanence.extraDirectories = ["/var/lib/noctalia-greeter"];

    services.displayManager.noctalia-greeter = {
      enable = true;

      settings.cursor = {
        inherit (config.home-manager.users.${config.internal.primaryUser}.home.pointerCursor) name size;
        path = "${pkgs.bibata-cursors}/share/icons";
      };
    };
  };
}

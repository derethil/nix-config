{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.noctalia-greeter = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:noctalia-dev/noctalia-greeter";
  };

  flake.modules.nixos.noctalia-greeter = {config, ...}: {
    imports = [
      inputs.noctalia-greeter.nixosModules.default
      self.modules.nixos.primary-user
    ];

    internal.boot.impermanence.extraDirectories = ["/var/lib/noctalia-greeter"];

    services.displayManager.noctalia-greeter = {
      enable = true;

      settings.cursor = let
        cursor = config.home-manager.users.${config.internal.primaryUser}.home.pointerCursor;
      in {
        inherit (cursor) size;
        path = "${cursor.package}/share/icons";
        theme = cursor.name;
      };
    };
  };
}

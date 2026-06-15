{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=latest";
  };

  flake.modules.nixos.flatpak = {
    imports = [
      inputs.nix-flatpak.nixosModules.nix-flatpak
      self.modules.nixos.portals
    ];

    services.flatpak = {
      enable = true;
      update.auto = {
        enable = true;
        onCalendar = "Sun *-*-* 02:00:00";
      };
    };

    internal.boot.impermanence.extraDirectories = [
      "/var/lib/flatpak"
      "/var/cache/flatpak"
    ];
  };
}

{...}: {
  flake.modules.nixos.geoclue = {
    services.geoclue2.enable = true;

    internal.boot.impermanence.extraDirectories = ["/var/lib/geoclue"];
  };
}

{
  flake.modules.nixos.geoclue = {
    internal.boot.impermanence.extraDirectories = ["/var/lib/geoclue"];
    services.geoclue2.enable = true;
  };
}

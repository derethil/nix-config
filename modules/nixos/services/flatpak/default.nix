{
  lib,
  config,
  pkgs,
  ...
}:
let
  inherit (lib) types mkIf;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.services.flatpak;
in {
  options.glace.services.flatpak = {
    enable = mkBoolOpt false "Whether to enable flatpak support";
    packages = mkOpt (types.listOf types.attrs) [] "Packages to install with Flatpak.";
  };

  config = mkIf cfg.enable {
    services.flatpak = {
      enable = true;
      inherit (cfg) packages;
      update.auto = {
        enable = true;
        onCalendar = "weekly";
      };
    };

    # flatpak requires xdg portals
    glace.services.portals = {
      enable = true;
      portals = [pkgs.kdePackages.xdg-desktop-portal-kde];
      config.common.default = "kde";
    };

    glace.system.impermanence.extraDirectories = [
      "/var/lib/flatpak"
      "/var/cache/flatpak"
    ];
  };
}

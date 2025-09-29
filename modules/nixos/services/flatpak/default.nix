{
  lib,
  config,
  ...
}:
with lib; let
  inherit (lib) types;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.services.flatpak;
in {
  options.services.flatpak = {
    enable = mkBoolOpt false "Whether to enable flatpak support";
    packages = mkOpt types.attr {} "Packages to install with Flatpak.";
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

    system.impermanence.extraDirectories = [
      "/var/lib/flatpak"
      "/var/cache/flatpak"
    ];
  };
}

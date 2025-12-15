{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  cfg = config.glace.desktop.niri;
in {
  config = mkIf cfg.enable {
    home.sessionVariables = mkMerge [
      (mkIf config.glace.hardware.nvidia-drivers.enable {
        LIBVA_DRIVER_NAME = "nvidia";
        XDG_SESSION_TYPE = "wayland";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
        NVD_BACKEND = "direct"; # libva-nvidia-driver, hardware video acceleration
      })

      {
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_QPA_PLATFORMTHEME = "gtk3";
        QT_QPA_PLATFORMTHEME_QT6 = "gtk3";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        MOZ_ENABLE_WAYLAND = "1";
        MOZ_USE_XINPUT2 = "1";

        # Niri
        XDG_SESSION_DESKTOP = "niri";
        XDG_CURRENT_DESKTOP = "niri";

        # Wayland
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        NIXOS_OZONE_WL = "1"; # some applications don't respect ELECTRON_OZONE_PLATFORM_HINT
      }
    ];
  };
}

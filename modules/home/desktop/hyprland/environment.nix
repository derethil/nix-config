{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.hyprland;
in {
  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      settings.environment = flatten [
        (optionals config.hardware.nvidia.enable [
          "LIBVA_DRIVER_NAME, nvidia"
          "XDG_SESSION_TYPE, wayland"
          "GBM_BACKEND, nvidia-drm"
          "__GLX_VENDOR_LIBRARY_NAME, nvidia"
          "NVD_BACKEND, direct # libva-nvidia-driver, hardware video acceleration"
        ])

        # WLRoots
        "QT_QPA_PLATFORM, wayland;xcb"
        "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
        "MOZ_ENABLE_WAYLAND, 1"
        "MOZ_USE_XINPUT2, 1"

        # Hyprland
        "XDG_SESSION_DESKTOP, Hyprland"
        "XDG_CURRENT_DESKTOP, Hyprland"
        "HYPRLAND_LOG_WLR, 1"

        # Wayland
        "ELECTRON_OZONE_PLATFORM_HINT, auto"
      ];
    };
  };
}

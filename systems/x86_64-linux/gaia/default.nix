{
  lib,
  pkgs,
  ...
}: let
  inherit (lib.glace) enabled disabled enabled';
in {
  imports = [
    ./hardware.nix
    ./disko.nix
  ];

  glace = {
    apps = {
      steam = enabled;
      sober = enabled;
      lutris = disabled;
      faugus-launcher = enabled;
      bongocat = enabled;
      starcitizen = enabled;
    };
    cli = {
      fish = enabled;
      yazi.portal = enabled;
    };
    tools = {
      nh = enabled;
      wine = enabled;
      comma = enabled;
      development = {
        neovim = enabled;
      };
    };
    hardware = {
      audio = enabled;
      bluetooth = enabled;
      radeon = enabled' {
        mesa.useUnstable = true;
        ppfeaturemask = "0xfff7ffff";
      };
      networking = enabled' {
        avahi = enabled;
      };
    };
    services = {
      gnome-keyring = enabled;
      locate = enabled;
      openssh = enabled;
      openrgb = enabled' {
        startupProfile = "Minimal";
      };
      lact = enabled;
      coolercontrol = enabled' {
        it87 = enabled' {
          mmio = true;
        };
      };
      flatpak = enabled;
      szuru = enabled;
      sideloading = enabled;
      sunshine = enabled;
    };
    system = {
      impermanence = enabled;
      swap.zram = enabled;
      time = enabled;
      fonts = enabled;
      ntsync = enabled;
      boot = enabled' {
        plymouth = enabled;
        kernel = {
          cachyos = enabled;
          params = [
            "xhci_hcd.quirks=64" # fix some Intel xHCI USB controller issues
            "pcie_aspm=off" # seems to fix intermittent WiFi card detection issues
          ];
        };
        ssh = enabled;
      };
    };
    nix = {
      config = enabled;
    };
    desktop = {
      hyprland = disabled;
      niri = enabled' {
        nvidia.limitVramHeap = true;
      };
      displayManagers = {
        tuigreet = disabled;
        dankGreeter = enabled;
      };
      addons = {
        dconf = enabled;
      };
    };
  };

  # ath12k (WiFi 7 chip) initializes with 1 dBm TX power on some channels (notably ch36),
  # causing association timeouts. Re-apply 19 dBm whenever the interface comes up.
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "fix-ath12k-txpower" ''
        if [ "$1" = "wlp15s0" ] && [ "$2" = "up" ]; then
          ${pkgs.iw}/bin/iw dev wlp15s0 set txpower fixed 1900
        fi
      '';
      type = "basic";
    }
  ];

  system.stateVersion = "25.11";
}

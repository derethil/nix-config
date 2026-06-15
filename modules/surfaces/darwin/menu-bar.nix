{lib, ...}: {
  flake.modules.darwin.menu-bar = {
    system.defaults = {
      controlcenter = {
        AirDrop = true;
        BatteryShowPercentage = true;
        Bluetooth = false;
        Display = false;
        FocusModes = true;
        NowPlaying = lib.mkDefault true;
        Sound = true;
      };

      menuExtraClock = {
        ShowAMPM = true;
      };

      hitoolbox = {
        AppleFnUsageType = "Show Emoji & Symbols";
      };
    };
  };
}

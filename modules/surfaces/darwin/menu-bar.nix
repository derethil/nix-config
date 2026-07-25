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

      hitoolbox.AppleFnUsageType = "Show Emoji & Symbols";
      menuExtraClock.ShowAMPM = true;
    };
  };
}

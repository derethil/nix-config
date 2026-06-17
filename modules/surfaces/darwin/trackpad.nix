{
  flake.modules.darwin.trackpad = {
    system.defaults = {
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad".TrackpadThreeFingerHorizSwipeGesture = 0;
        "com.apple.driver.AppleBluetoothMultitouch.trackpad".TrackpadThreeFingerHorizSwipeGesture = 0;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true; # natural scrolling
        "com.apple.sound.beep.feedback" = 0; # no beep on volume change
      };
    };
  };
}

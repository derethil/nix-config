{
  flake.modules.darwin.trackpad = {
    system.defaults = {
      CustomUserPreferences = {
        "com.apple.AppleMultitouchTrackpad".TrackpadThreeFingerHorizSwipeGesture = 0;
        "com.apple.driver.AppleBluetoothMultitouch.trackpad".TrackpadThreeFingerHorizSwipeGesture = 0;
      };

      NSGlobalDomain = {
        "com.apple.sound.beep.feedback" = 0; # no beep on volume change
        "com.apple.swipescrolldirection" = true; # natural scrolling
      };

      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };
    };
  };
}

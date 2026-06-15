{
  flake.modules.darwin.trackpad = {
    system.defaults = {
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = false;
      };

      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true; # natural scrolling
        "com.apple.sound.beep.feedback" = 0; # no beep on volume change
      };
    };
  };
}

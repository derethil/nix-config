{
  flake.modules.darwin.window-manager = {
    system.defaults = {
      CustomUserPreferences.NSGlobalDomain = {
        NSQuitAlwaysKeepsWindows = false;

        NSUserKeyEquivalents = {
          "Enter Full Screen" = "@f";
          "Exit Full Screen" = "@f";
        };
      };

      NSGlobalDomain = {
        AppleSpacesSwitchOnActivate = true;
        NSAutomaticWindowAnimationsEnabled = true;
        NSWindowShouldDragOnGesture = true;
      };

      WindowManager = {
        AutoHide = true; # auto-hide recent apps in stage
        EnableStandardClickToShowDesktop = false;
        EnableTilingOptionAccelerator = true;
        EnableTopTilingByEdgeDrag = true;
        StandardHideDesktopIcons = false;
      };

      spaces.spans-displays = false;
    };
  };
}

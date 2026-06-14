{
  flake.modules.darwin.window-manager = {
    system.defaults = {
      WindowManager = {
        AutoHide = true; # auto-hide recent apps in stage
        EnableStandardClickToShowDesktop = false;
        EnableTilingOptionAccelerator = true;
        EnableTopTilingByEdgeDrag = true;
        StandardHideDesktopIcons = false;
      };

      spaces = {
        spans-displays = false;
      };

      NSGlobalDomain = {
        AppleSpacesSwitchOnActivate = true;
        NSAutomaticWindowAnimationsEnabled = true;
        NSWindowShouldDragOnGesture = true;
      };
    };
  };
}

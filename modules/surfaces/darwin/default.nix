{self, ...}: {
  flake.modules.darwin.darwin-surfaces = {
    imports = with self.modules.darwin; [
      dock
      night-shift
      hotkeys
      menu-bar
      finder
      screencapture
      trackpad
      appearance
      window-manager
      ical
      login
      fonts
    ];
  };
}

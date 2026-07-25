{self, ...}: {
  flake.modules.darwin.darwin-surfaces = {
    imports = with self.modules.darwin; [
      appearance
      dock
      finder
      fonts
      hotkeys
      ical
      login
      menu-bar
      night-shift
      screencapture
      trackpad
      window-manager
    ];
  };
}

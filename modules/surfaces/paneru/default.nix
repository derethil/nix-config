{self, ...}: {
  flake.modules.homeManager.paneru = {
    imports = with self.modules.homeManager; [
      fonts
    ];
  };
}

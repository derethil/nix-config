{self, ...}: {
  flake.modules.darwin.bridges = {
    imports = with self.modules.darwin; [
      homebrew
      mac-app-util
      reset-launch-services
      settings
    ];
  };
}

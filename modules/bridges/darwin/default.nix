{self, ...}: {
  flake.modules.darwin.bridges = {
    imports = with self.modules.darwin; [
      mac-app-util
      homebrew
      reset-launch-services
      settings
    ];
  };
}

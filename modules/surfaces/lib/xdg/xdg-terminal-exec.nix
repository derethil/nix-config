{self, ...}: {
  flake.modules.homeManager.xdg-terminal-exec = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [self.modules.homeManager.terminal-options];

    config = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
      xdg.terminal-exec = {
        enable = true;
        package = pkgs.xdg-terminal-exec;
        settings.default = config.terminal.desktopFiles;
      };
    };
  };
}

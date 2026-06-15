{self, ...}: let
  common = [
    self.modules.generic.shell-options
    self.modules.generic.shell-defaults
  ];
in {
  flake.modules.homeManager.shell-consumer = {config, ...}: {
    key = "shell-consumer";
    imports = common;
    home.shellAliases = config.shell.aliases;
  };

  flake.modules.nixos.shell-consumer = {config, ...}: {
    key = "shell-consumer";
    imports = common;
    environment.shellAliases = config.shell.aliases;
  };

  flake.modules.darwin.shell-consumer = {config, ...}: {
    key = "shell-consumer";
    imports = common;
    environment.shellAliases = config.shell.aliases;
  };
}

{self, ...}: let
  common = [
    self.modules.generic.shell-defaults
    self.modules.generic.shell-options
  ];
in {
  flake.modules = {
    nixos.shell-consumer = {config, ...}: {
      key = "shell-consumer";
      imports = common;
      environment.shellAliases = config.shell.aliases;
    };

    darwin.shell-consumer = {config, ...}: {
      key = "shell-consumer";
      imports = common;
      environment.shellAliases = config.shell.aliases;
    };

    homeManager.shell-consumer = {config, ...}: {
      key = "shell-consumer";
      imports = common;
      home.shellAliases = config.shell.aliases;
    };
  };
}

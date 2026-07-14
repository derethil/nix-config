{
  self,
  lib,
  ...
}: {
  flake.modules = {
    generic.hammerspoon-options = {
      key = "hammerspoon-options";

      options.hammerspoon.scripts = lib.mkOption {
        default = [];
        type = lib.types.listOf lib.types.lines;
      };
    };

    darwin.hammerspoon = {
      imports = [self.modules.darwin.homebrew];
      home-manager.sharedModules = [self.modules.homeManager.hammerspoon];
      homebrew.casks = ["hammerspoon"];

      system.defaults.CustomUserPreferences."org.hammerspoon.Hammerspoon" = {
        SUAutomaticallyUpdate = false;
        SUEnableAutomaticChecks = false;
        SUHasLaunchedBefore = true;
        SUSendProfileInfo = false;
      };
    };

    homeManager.hammerspoon = {config, ...}: {
      imports = [
        self.modules.generic.hammerspoon-options
        self.modules.homeManager.hammerspoon-messages
      ];

      home.file.".hammerspoon/init.lua".text =
        lib.concatStringsSep "\n\n" config.hammerspoon.scripts;

      launchd.agents.hammerspoon.config = {
        KeepAlive = false;
        ProgramArguments = ["/Applications/Hammerspoon.app/Contents/MacOS/Hammerspoon"];
        RunAtLoad = true;
      };
    };
  };
}

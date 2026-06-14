{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    mac-app-util.url = "github:hraban/mac-app-util";
  };

  flake.modules.darwin.mac-app-util = {
    imports = [inputs.mac-app-util.darwinModules.default];
    config.home-manager.sharedModules = [self.modules.homeManager.mac-app-util];
  };

  flake.modules.homeManager.mac-app-util = {
    key = "hm-mac-app-util";
    imports = [inputs.mac-app-util.homeManagerModules.default];
  };
}

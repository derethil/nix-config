{
  self,
  inputs,
  ...
}: {
  flake-file.inputs = {
    # TODO: revert to hraban/mac-app-util once PR #44 (fix/missing-icons) merges
    mac-app-util.url = "github:mcflis/mac-app-util/fix/missing-icons";
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

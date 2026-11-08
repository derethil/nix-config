{
  self,
  lib,
  ...
}: let
  inherit (lib) functionArgs isFunction setFunctionArgs;
  inherit (self.lib.podman) user;
in {
  config.flake.factory.container-app = {
    name,
    nixos,
    quadlet,
  }: let
    toModule = f: setFunctionArgs (args: {virtualisation.quadlet = f args;}) (functionArgs f);
  in {
    nixos.${name} = {
      key = "container-app-${name}";

      imports = [
        nixos
        {home-manager.users.${user}.imports = [self.modules.homeManager.${name}];}
      ];
    };

    homeManager.${name} =
      if isFunction quadlet
      then toModule quadlet
      else {virtualisation.quadlet = quadlet;};
  };
}

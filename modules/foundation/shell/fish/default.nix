{
  self,
  lib,
  ...
}: let
  inherit (lib) hasSuffix filterAttrs mapAttrs' nameValuePair removeSuffix mkMerge;
in {
  flake.modules = {
    homeManager.fish = {pkgs, ...}: let
      fishFiles = filterAttrs (n: _: hasSuffix ".fish" n) (builtins.readDir ./functions);
      fishFunctions = mapAttrs' (name: _: nameValuePair (removeSuffix ".fish" name) (builtins.readFile (./functions + "/${name}"))) fishFiles;
    in {
      imports = [
        self.modules.homeManager.shell-consumer
        self.modules.generic.fish-common
      ];

      shell.defaultShell = pkgs.fish;

      programs.fish.functions = mkMerge [
        fishFunctions
        {
          activate = "source ./.venv/bin/activate.fish";
        }
      ];

      home.packages = with pkgs.fishPlugins; [
        fzf
        done
      ];
    };

    nixos.fish = {pkgs, ...}: {
      imports = [
        self.modules.nixos.shell-consumer
        self.modules.generic.fish-common
      ];

      users.defaultUserShell = pkgs.fish;
    };

    darwin.fish = {
      pkgs,
      config,
      ...
    }: {
      imports = [
        self.modules.darwin.shell-consumer
        self.modules.generic.fish-common
      ];

      users.users = self.lib.forEachNormalUser config (_: {
        shell = pkgs.fish;
      });
    };
  };
}

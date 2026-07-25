{
  self,
  lib,
  ...
}: let
  inherit (lib) filterAttrs hasSuffix mapAttrs' mkMerge nameValuePair removeSuffix;
in {
  flake.modules = {
    nixos.fish = {pkgs, ...}: {
      imports = [
        self.modules.generic.fish-common
        self.modules.nixos.shell-consumer
      ];

      users.defaultUserShell = pkgs.fish;
    };

    darwin.fish = {
      config,
      pkgs,
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

    homeManager.fish = {pkgs, ...}: let
      fishFiles = filterAttrs (n: _: hasSuffix ".fish" n) (builtins.readDir ./functions);
      fishFunctions = mapAttrs' (name: _: nameValuePair (removeSuffix ".fish" name) (builtins.readFile (./functions + "/${name}"))) fishFiles;
    in {
      imports = [
        self.modules.generic.fish-common
        self.modules.homeManager.shell-consumer
      ];

      home.packages = with pkgs.fishPlugins; [
        done
        fzf
      ];

      programs.fish.functions = mkMerge [
        fishFunctions
        {
          activate = "source ./.venv/bin/activate.fish";
        }
      ];

      shell.defaultShell = pkgs.fish;
    };
  };
}

{self, ...}: {
  flake.modules.homeManager.fish = {pkgs, ...}: {
    imports = [
      self.modules.homeManager.shell-consumer
      self.modules.generic.fish-common
    ];

    programs.fish.functions = {
      activate = "source ./.venv/bin/activate.fish";
      go-coverage = builtins.readFile ./_functions/go-coverage.fish;
    };

    home.packages = with pkgs.fishPlugins; [
      fzf
      done
    ];
  };

  flake.modules.nixos.fish = {pkgs, ...}: {
    imports = [
      self.modules.nixos.shell-consumer
      self.modules.generic.fish-common
    ];

    users.defaultUserShell = pkgs.fish;
  };

  flake.modules.darwin.fish = {pkgs, ...}: {
    imports = [
      self.modules.darwin.shell-consumer
      self.modules.generic.fish-common
    ];

    # TODO: find a way to set default user shell on darwin
  };
}

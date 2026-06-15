{inputs, ...}: {
  flake-file.inputs.tmux-theme = {
    url = "github:derethil/tmux-theme";
    flake = false;
  };

  perSystem = {pkgs, ...}: {
    packages.tmux-theme = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-theme";
      version = "flake-input";
      src = inputs.tmux-theme;
    };
  };
}

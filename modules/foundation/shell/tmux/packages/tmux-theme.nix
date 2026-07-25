{inputs, ...}: {
  flake-file.inputs.tmux-theme = {
    flake = false;
    url = "github:derethil/tmux-theme";
  };

  perSystem = {pkgs, ...}: {
    packages.tmux-theme = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "tmux-theme";
      src = inputs.tmux-theme;
      version = "flake-input";
    };
  };
}

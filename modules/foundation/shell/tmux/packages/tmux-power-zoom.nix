{inputs, ...}: {
  flake-file.inputs.tmux-power-zoom = {
    flake = false;
    url = "github:jaclu/tmux-power-zoom";
  };

  perSystem = {pkgs, ...}: {
    packages.tmux-power-zoom = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "power-zoom";
      src = inputs.tmux-power-zoom;
      version = "flake-input";
    };
  };
}

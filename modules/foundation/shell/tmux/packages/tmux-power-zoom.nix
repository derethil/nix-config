{inputs, ...}: {
  flake-file.inputs.tmux-power-zoom = {
    url = "github:jaclu/tmux-power-zoom";
    flake = false;
  };

  perSystem = {pkgs, ...}: {
    packages.tmux-power-zoom = pkgs.tmuxPlugins.mkTmuxPlugin {
      pluginName = "power-zoom";
      version = "flake-input";
      src = inputs.tmux-power-zoom;
    };
  };
}

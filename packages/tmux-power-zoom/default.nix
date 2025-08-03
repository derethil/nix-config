{
  pkgs,
  inputs,
  ...
}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-power-zoom";
  version = "flake-input";
  src = inputs.tmux-power-zoom;
}
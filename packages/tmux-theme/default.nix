{
  pkgs,
  inputs,
  ...
}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "tmux-theme";
  version = "flake-input";
  src = inputs.tmux-theme;
}
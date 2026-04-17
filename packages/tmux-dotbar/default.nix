{
  pkgs,
  inputs,
  ...
}:
pkgs.tmuxPlugins.mkTmuxPlugin {
  pluginName = "dotbar";
  version = "flake-input";
  src = inputs.tmux-dotbar;
}

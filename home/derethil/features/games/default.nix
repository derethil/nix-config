{
  pkgs,
  config,
  ...
}: {
  home.packages = with pkgs; [
    gdlauncher-carbon
    heroic
    (config.lib.nixGL.wrap steam)
  ];
}

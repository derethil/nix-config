{pkgs, ...}: {
  imports = [
    ./mattermost.nix
  ];

  home.packages = with pkgs; [
    insomnia
  ];
}

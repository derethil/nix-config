{
  lib,
  config,
  ...
}: {
  imports = [
    ./xdg.nix
  ];

  home = {
    username = lib.mkDefault "derethil";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
  };
}

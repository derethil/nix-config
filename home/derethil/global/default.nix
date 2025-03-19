{
  pkgs,
  builtins,
  lib,
  config,
  ...
}: {
  imports = [
    ../features/cli
  ];

  home = {
    username = lib.mkDefault "derethil";
    homeDirectory = lib.mkDefault "/home/${config.home.username}";
    stateVersion = lib.mkDefault "24.11";
  };
}

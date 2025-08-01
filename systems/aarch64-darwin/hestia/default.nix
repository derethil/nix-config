{lib, ...}: let
  inherit (lib.internal) enabled;
in {
  user = {
    name = "derethil";
    userdirs = enabled;
  };
  system = {
    fonts = enabled;
    nix = enabled;
  };
  cli = {
    fish = enabled;
  };

  system.stateVersion = 5;
}

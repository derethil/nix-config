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
    keyboard = enabled;
  };
  cli = {
    fish = enabled;
  };
  tools = {
    darwin-option = true;
  };

  system.stateVersion = 5;
}

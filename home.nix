{ config, pkgs, ... }:

{
  home = {
    username = "derethil";
    homeDirectory = "/home/derethil";
    stateVersion = "24.11"; 

    packages = [pkgs.hello];

    file = {};

    sessionVariables = {};
  };
}

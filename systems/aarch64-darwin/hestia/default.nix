{pkgs, ...}: {
  system.stateVersion = 5;

  users.users.derethil = {
    shell = pkgs.fish;
  };

  system.fonts.enable = true;
}

{pkgs, ...}: {
  home.packages = with pkgs; [
    r2modman
  ];

  xdg.desktopEntries.r2modman = {
    name = "R2ModMan";
    exec = "${pkgs.r2modman}/bin/r2modman -- %u";
    terminal = false;
    type = "Application";
    categories = ["Game"];
  };
}

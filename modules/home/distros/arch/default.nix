{lib, ...}:
with lib;
with internal; {
  config = mkIf (platform.isArch) {
    cli.abbreviations = {
      paca = "pacman -S"; # install
      pacu = "pacman -Syua"; # update
      pacr = "pacman -Rns"; # remove
      pacs = "pacman -Ss"; # search
      paci = "pacman -Si"; # info
      paclo = "pacman -Qdt"; # list orphans
      pacro = "pacman -Qdt && sudo pacman -Rns $(pacman -Qtdq)"; # remove orphans
      pacc = "pacman -Scc"; # clean cache
      paclf = "pacman -Ql"; # list files

      yaya = "yay -S"; # install
      yayr = "yay -Rns"; # remove
      yays = "yay -Ss"; # search
      yayi = "yay -Si"; # info
      yaylo = "yay -Qdt"; # list orphans
      yayro = "yay -Qdt && yay -Rns $(yay -Qtdq)"; # remove orphans
      yayc = "yay -Scc"; # clean cache
      yaylf = "yay -Ql"; # list files
      yayo = "yay -O"; # open AUR page
    };
  };
}

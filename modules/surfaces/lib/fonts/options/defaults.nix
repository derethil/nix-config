{...}: {
  config.flake.factory.fonts-defaults = {pkgs}: {
    font = {
      serif = {
        name = "IBM Plex Serif";
        package = pkgs.ibm-plex.override {families = ["serif"];};
      };
      sansSerif = {
        name = "Inter Variable Medium";
        package = pkgs.inter;
      };
      monospace = {
        name = "GeistMono Nerd Font Mono";
        size = 12;
        style = "SemiBold";
        package = pkgs.nerd-fonts.geist-mono;
      };
      emoji = {
        name = "Noto Color Emoji";
        package = pkgs.noto-fonts-color-emoji;
      };
      extraPackages = with pkgs; [
        dejavu_fonts
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        nerd-fonts.gohufont
      ];
    };
  };
}

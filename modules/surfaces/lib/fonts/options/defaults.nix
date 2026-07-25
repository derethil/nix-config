{
  config.flake.factory.fonts-defaults = {pkgs}: {
    font = {
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };

      extraPackages = with pkgs; [
        dejavu_fonts
        nerd-fonts.gohufont
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
      ];

      monospace = {
        package = pkgs.nerd-fonts.geist-mono;
        name = "GeistMono Nerd Font Mono";
        size = 12;
        style = "SemiBold";
      };

      sansSerif = {
        package = pkgs.inter;
        name = "Inter Variable Medium";
      };

      serif = {
        package = pkgs.ibm-plex.override {families = ["serif"];};
        name = "IBM Plex Serif";
      };
    };
  };
}

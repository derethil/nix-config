{pkgs, ...}: {
  programs.firefox.package = pkgs.firefox.override {
    nativeMessagingHosts = with pkgs; [
      tridactyl-native
    ];
  };

  xdg.configFile."tridactyl/tridactylrc".text = ''
    set theme midnight

    bind <d tabclosealltoleft
    bind >d tabclosealltoright
  '';
}

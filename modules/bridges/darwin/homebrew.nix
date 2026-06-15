{
  flake.modules.darwin.homebrew = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      mas
    ];

    homebrew = {
      enable = true;
      masApps = {};
      casks = [];
      onActivation = {
        cleanup = "zap";
      };
    };
  };
}

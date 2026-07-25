{
  flake.modules.darwin.homebrew = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      mas
    ];

    homebrew = {
      enable = true;
      casks = [];
      masApps = {};
      onActivation.cleanup = "zap";
    };
  };
}

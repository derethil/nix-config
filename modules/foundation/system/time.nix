{
  flake.modules.nixos.time = {
    services.automatic-timezoned = {
      enable = true;
    };
  };
}

{
  flake.modules.nixos.time = {
    services.automatic-timezoned.enable = false;
    time.timeZone = "America/Denver";
  };
}

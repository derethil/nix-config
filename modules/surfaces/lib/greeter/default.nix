{...}: {
  flake.modules.nixos.greeter = {
    services.displayManager.enable = true;
  };
}

{lib, ...}:
with lib;
with internal; {
  system = {
    time = enabled;
    boot = {
      enable = true;
      plymouth = enabled;
    };
  };
  hardware = {
    brillo = enabled;
  };
  security = {
    keyring = enabled;
  };
}

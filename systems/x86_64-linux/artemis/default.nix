{lib, ...}:
with lib;
with internal; {
  system = {
    time = enabled;
  };
  hardware = {
    brillo = enabled;
  };
  security = {
    keyring = enabled;
  };
}

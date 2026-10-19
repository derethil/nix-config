{
  flake.modules.darwin.mos = {pkgs, ...}: {
    environment.systemPackages = [pkgs.mos];

    system.defaults.CustomUserPreferences."com.caldis.Mos" = {
      duration = 3.35;
      reverse = true;
      reverseHorizontal = true;
      reverseVertical = true;
      smooth = true;
      smoothHorizontal = true;
      smoothVertical = true;
      speed = 2.1;
    };
  };
}

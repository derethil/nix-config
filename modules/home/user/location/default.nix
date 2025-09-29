{lib, ...}:
with lib;
with glace;
with types; {
  options.glace.user.location = {
    latitude = mkOpt (types.nullOr types.float) null "Location latitude.";
    longitude = mkOpt (types.nullOr types.float) null "Location longitude.";
  };
}

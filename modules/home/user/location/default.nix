{lib, ...}:
with lib;
with internal;
with types; {
  options.user.location = {
    latitude = mkOpt (types.nullOr types.float) null "Location latitude.";
    longitude = mkOpt (types.nullOr types.float) null "Location longitude.";
  };
}

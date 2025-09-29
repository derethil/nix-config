{lib, ...}: let
  inherit (lib) types;
  inherit (lib.glace) mkOpt;
in {
  options.glace.user.location = {
    latitude = mkOpt (types.nullOr types.float) null "Location latitude.";
    longitude = mkOpt (types.nullOr types.float) null "Location longitude.";
  };
}

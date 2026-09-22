{lib, ...}: {
  flake.lib.gatus = let
    # Mirror Gatus's own key normalization
    normalize = s: lib.toLower (lib.replaceStrings ["," "/" "_" " " "." "#"] ["-" "-" "-" "-" "-" "-"] s);
    externalKey = group: name: "${normalize group}_${normalize name}";

    inherit (lib) boolToString getExe;
    inherit (lib.cli) toCommandLineShellGNU;
  in {
    inherit externalKey;

    # Requires GATUS_URL and GATUS_TOKEN in the environment
    mkPush = {
      pkgs,
      group,
      name,
      success,
      error ? null,
    }: let
      gatus = "${getExe pkgs.gatus-cli}";

      args = toCommandLineShellGNU {} {
        inherit error;
        key = externalKey group name;
        success = boolToString success;
      };
    in "${gatus} external-endpoint push --url $GATUS_URL --token $GATUS_TOKEN ${args}";
  };
}

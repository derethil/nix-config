{lib, ...}: {
  flake = {
    modules.homeManager.mimeapps = {
      config,
      lib,
      pkgs,
      ...
    }: let
      inherit (lib) attrNames concatStringsSep filter isList length mkIf optionals;
      inherit (pkgs.stdenv.hostPlatform) isLinux;

      defaults = config.xdg.mimeApps.defaultApplications;

      duplicates =
        filter
        (mime: let v = defaults.${mime}; in isList v && length v > 1)
        (attrNames defaults);
    in {
      xdg.mimeApps.enable = mkIf isLinux true;

      assertions = optionals isLinux [
        {
          assertion = duplicates == [];

          message = ''
            The following MIME types have multiple default applications defined: ${concatStringsSep ", " duplicates}

            Each MIME type can only have one default application.
          '';
        }
      ];
    };

    lib.mkMimeApps = app: mimes: lib.genAttrs mimes (_: [app]);
  };
}

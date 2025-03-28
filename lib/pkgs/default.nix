{pkgs}: let
  inherit (builtins) readFile fromJSON;
in {
  buildNodeModules = dir: npmDepsHash: let
    packageJSON = fromJSON (readFile dir + /package.json);
    pkg = pkgs.callPackage ({buildNpmPackage, ...}:
      buildNpmPackage {
        pname = packageJSON.name;
        inherit (packageJSON) version;

        src = dir;

        inherit npmDepsHash;
        dontNpmBuild = true;
      }) {};
  in "${pkg}/lib/node_modules/${pkg.pname}/node_modules";
}

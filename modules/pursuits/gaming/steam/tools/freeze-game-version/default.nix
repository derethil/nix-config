{...}: {
  perSystem = {pkgs, ...}: {
    packages.freeze-game-version = pkgs.writeShellScriptBin "freeze-game-version" ''
      export CHATTR="${pkgs.e2fsprogs}/bin/chattr"
      export LSATTR="${pkgs.e2fsprogs}/bin/lsattr"
      exec ${pkgs.python3}/bin/python3 ${./freeze-game-version.py} "$@"
    '';
  };
}

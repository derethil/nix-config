{pkgs}:
pkgs.writeScriptBin "niri-dynamic-float-rules" ''
  #!${pkgs.python3}/bin/python3
  ${builtins.readFile ./niri-dynamic-float-rules.py}
''
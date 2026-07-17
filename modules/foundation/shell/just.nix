{
  flake.modules = {
    homeManager.just = {
      pkgs,
      lib,
      ...
    }: {
      home.packages = [pkgs.just];

      programs = {
        fish.completions.just = ''
          JUST_COMPLETE=fish just | source
        '';

        bash.initExtra = ''
          source <(just --completions bash)
        '';

        zsh.initContent = lib.mkBefore ''
          fpath+=(${pkgs.runCommand "just-zsh-completions" {} ''
            mkdir -p $out
            ${pkgs.just}/bin/just --completions zsh > $out/_just
          ''})
        '';
      };
    };
  };
}

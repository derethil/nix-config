{
  flake.modules.homeManager.just = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.just];

    programs = {
      bash.initExtra = ''
        source <(just --completions bash)
      '';

      fish.completions.just = ''
        JUST_COMPLETE=fish just | source
      '';

      zsh.initContent = lib.mkBefore ''
        fpath+=(${pkgs.runCommand "just-zsh-completions" {} ''
          mkdir -p $out
          ${pkgs.just}/bin/just --completions zsh > $out/_just
        ''})
      '';
    };
  };
}

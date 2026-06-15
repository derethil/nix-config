{lib, ...}: {
  flake.modules.generic.fish-common = {
    config,
    pkgs,
    ...
  }: {
    programs.fish = lib.mkMerge [
      {
        enable = true;
        shellAbbrs = config.shell.abbreviations;

        interactiveShellInit = ''
          set fish_greeting
          fish_vi_key_bindings
          set fish_cursor_default     block      blink
          set fish_cursor_insert      line       blink
          set fish_cursor_replace_one underscore blink
          set fish_cursor_visual      block

          ${builtins.readFile ./_theme.fish}

          ${lib.getExe pkgs.any-nix-shell} fish --info-right | source
        '';
      }
      (lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        generateCompletions = true;
      })
    ];
  };
}

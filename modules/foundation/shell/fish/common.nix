{lib, ...}: let
  inherit (lib) getExe mkMerge optionalAttrs;
  inherit (lib.attrsets) mapAttrs;
in {
  flake.modules.generic.fish-common = {
    config,
    pkgs,
    ...
  }: {
    programs.fish = mkMerge [
      (optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        generateCompletions = true;
      })
      {
        enable = true;

        interactiveShellInit = ''
          set fish_greeting
          fish_vi_key_bindings
          set fish_cursor_default     block      blink
          set fish_cursor_insert      line       blink
          set fish_cursor_replace_one underscore blink
          set fish_cursor_visual      block

          bind -M insert \cf forward-char

          ${builtins.readFile ./theme.fish}

          ${getExe pkgs.any-nix-shell} fish --info-right | source
        '';

        shellAbbrs =
          mapAttrs (_: value: {
            expansion = value;
            position = "anywhere";
          })
          config.shell.abbreviations;
      }
    ];
  };
}

{lib, ...}: let
  inherit (lib) mkMerge optionalAttrs getExe;
  inherit (lib.attrsets) mapAttrs;
in {
  flake.modules.generic.fish-common = {
    config,
    pkgs,
    ...
  }: {
    programs.fish = mkMerge [
      {
        enable = true;
        shellAbbrs =
          mapAttrs (_: value: {
            expansion = value;
            position = "anywhere";
          })
          config.shell.abbreviations;

        interactiveShellInit = ''
          set fish_greeting
          fish_vi_key_bindings
          set fish_cursor_default     block      blink
          set fish_cursor_insert      line       blink
          set fish_cursor_replace_one underscore blink
          set fish_cursor_visual      block

          ${builtins.readFile ./theme.fish}

          ${getExe pkgs.any-nix-shell} fish --info-right | source
        '';
      }
      (optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        generateCompletions = true;
      })
    ];
  };
}

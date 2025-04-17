{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./theme.nix
    ./arch.nix
  ];

  programs.fish = {
    enable = true;

    interactiveShellInit = ''
      fish_vi_key_bindings
      set fish_cursor_default     block      blink
      set fish_cursor_insert      line       blink
      set fish_cursor_replace_one underscore blink
      set fish_cursor_visual      block
    '';

    shellAbbrs = {
      be = "bundle exec";
    };

    shellAliases = {
      l = "eza -la --icons --group-directories-first";
      lt = "eza --tree --icons --group-directories-first --level=3";
      cat = "bat";
      btm = "btm --enable_gpu";
      del = "trashy put";
      nv = "nvim";
      udb = "sudo updatedb";
      agsv2 = "ags run --directory ~/.config/astal";
      wget = "wget --hsts-file=$XDG_DATA_HOME/wget-hsts";
      hueadm = "hueadm --config ~/.config/.hueadm.json";
    };

    functions = {
      activate = "source ./.venv/bin/activate.fish";
      fish_greeting = lib.readFile ./fish_greeting.fish;
    };
  };

  home.packages = with pkgs.fishPlugins; [
    fzf
    done
  ];
}

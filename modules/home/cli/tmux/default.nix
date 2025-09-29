{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.cli.tmux;

  themes = ./themes;
  modules = ./modules;
in {
  options.glace.cli.tmux = {
    enable = mkBoolOpt false "Whether to enable Tmux";
    extraVariables = mkOpt (types.listOf types.str) [] "Additional environment variables to refresh in tmux sessions.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      package = pkgs.glace.tmux-wrapper.override {inherit config lib;};
      enable = true;
      shell = mkIf (!pkgs.stdenv.isDarwin) "${pkgs.fish}/bin/fish";
      terminal = "tmux-256color";
      prefix = "C-Space";
      keyMode = "vi";
      customPaneNavigationAndResize = true;

      extraConfig = ''
        # Force fish shell on Darwin as it doesn't seem to work with just shell=
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          set-option -g default-shell "${pkgs.fish}/bin/fish"
          set-option -g default-command "${pkgs.fish}/bin/fish"
        ''}

        # True Color Support
        set -sa terminal-overrides ",*:Tc"

        # Undercurl Support
        set -sa terminal-overrides ',*:Smulx=\E[4::%p1%dm'

        # Underline Colors
        set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'

        # Reload Config
        unbind r
        bind r source-file ~/.config/tmux/tmux.conf

        # Enable Mouse Support
        set -g mouse on

        # Fix Scrolling in Neovim
        bind -n WheelUpPane {
            if -F '#{==:#{window_name},nvim}' {
                send-keys -M
            } {
                copy-mode -e
            }
        }

        # Enable Yazi Image Preview
        set -g allow-passthrough on
        set -ga update-environment TERM
        set -ga update-environment TERM_PROGRAM

        # Start Windows and Panes at 1, not 0
        set -g base-index 1
        set -g pane-base-index 1
        set-window-option -g pane-base-index 1
        set-option -g renumber-windows on

        # Window Commands
        bind -T prefix w switch-client -T prefix_w
        bind -T prefix_w d kill-pane
        bind -T prefix_w m resize-pane -Z

        # Moving/Swapping Between Windows
        bind -n M-H previous-window
        bind -n M-L next-window
        bind -n C-M-H swap-window -t -1\; select-window -t -1
        bind -n C-M-L swap-window -t +1\; select-window -t +1

        # Fix Borders for Two Panes
        set -g pane-border-style bg=black,fg=blue
        set -g pane-active-border-style bg=black,fg=blue

        # Cycling Layouts
        bind l next-layout

        # Open in Current Directory
        bind - split-window -v -c "#{pane_current_path}"
        bind | split-window -h -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        # Copy Bindings
        bind -T copy-mode-vi v send-keys -X begin-selection
        bind -T copy-mode-vi C-v send-keys -X rectangle-toggle
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel

      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        vim-tmux-navigator
        {
          plugin = pkgs.glace.tmux-power-zoom;
          extraConfig = "";
        }
        {
          plugin = fzf-tmux-url;
          extraConfig = ''
            set -g @fzf-url-bind 'u'
          '';
        }
        {
          plugin = tmux-sessionx;
          extraConfig = ''
            set -g @sessionx-bind 'o'
            set -g @sessionx-zoxide-mode 'on'
            set -g @sessionx-custom-paths "${config.home.homeDirectory}/development/personal,${config.home.homeDirectory}/development/dragonarmy"
            set -g @sessionx-custom-paths-subdirectories "true"
            set -g @sessionx-bind-kill-session 'alt-x'
          '';
        }
        {
          plugin = pkgs.glace.tmux-theme;
          extraConfig = ''
            set -g @theme_custom_theme_dir "${themes}"
            set -g @theme_custom_plugin_dir "${modules}"
            set -g @theme_flavour "gruvbox-material"
            set -s status-interval 1

            set -g @theme_window_right_separator "█ "
            set -g @theme_window_number_position "right"
            set -g @theme_window_middle_separator " | "
            set -g @theme_window_default_fill "none"
            set -g @theme_window_current_fill "all"
            set -g @theme_window_default_text "#W"
            set -g @theme_window_current_text "#W"

            set -g @theme_window_current_color "#{thm_bg_bright}"
            set -g @theme_window_current_background "#{thm_bg}"

            set -g @theme_status_modules_right "directory continuum session"
            set -g @theme_directory_text "#( echo #{pane_current_path} | sed 's|$HOME|~|' | rev | cut -d'/' -f-3 | rev )"
          '';
        }
        {
          plugin = resurrect;
          extraConfig = ''
            set -g @resurrect-dir "${config.xdg.stateHome}/tmux/resurrect"
            set -g @resurrect-processes 'false'
            set -g @resurrect-save 'S'
            set -g @resurrect-restore 'R'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5'
          '';
        }
      ];
    };
  };
}

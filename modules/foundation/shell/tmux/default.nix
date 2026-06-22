{...}: {
  flake.modules.homeManager.tmux = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) getExe;

    is-vim = pkgs.callPackage ./_scripts/is-vim.nix {};
    refresh-env-pkg = pkgs.callPackage ./_scripts/refresh-env.nix {inherit config lib;};
    refresh-env = getExe refresh-env-pkg;
    tmux-pkg = pkgs.callPackage ./_scripts/tmux-wrapper.nix {inherit lib refresh-env;};
    continuum-status = pkgs.callPackage ./_scripts/continuum-status.nix {inherit lib;};

    themesDir = ./_themes;
    themeModulesDir = ./_modules;
  in {
    home.packages = [continuum-status];

    programs.tmux = {
      package = tmux-pkg;
      enable = true;
      # TODO: this needs to be shell-agnostic
      shell = "${getExe pkgs.fish}";
      terminal = "tmux-256color";
      prefix = "C-Space";
      keyMode = "vi";
      customPaneNavigationAndResize = true;

      extraConfig = ''
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
        ${lib.optionalString pkgs.stdenv.hostPlatform.isDarwin ''
          # User0/User1 are custom sequences sent by Alacritty for cmd+shift+h/l
          # see modules/surfaces/lib/terminal/alacritty.nix keyboard.bindings
          set -s user-keys[0] "\e[300~"
          set -s user-keys[1] "\e[301~"
          bind -n 'User0' previous-window
          bind -n 'User1' next-window
          bind H swap-window -t -1\; select-window -t -1
          bind L swap-window -t +1\; select-window -t +1
        ''}

        ${lib.optionalString (!pkgs.stdenv.hostPlatform.isDarwin) ''
          bind -n M-H previous-window
          bind -n M-L next-window
          bind -n C-M-H swap-window -t -1\; select-window -t -1
          bind -n C-M-L swap-window -t +1\; select-window -t +1
        ''}

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

        # Vim navigation keybindings
        bind-key -n 'C-h' if-shell '${getExe is-vim}' 'send-keys C-h' 'select-pane -L'
        bind-key -n 'C-j' if-shell '${getExe is-vim}' 'send-keys C-j' 'select-pane -D'
        bind-key -n 'C-k' if-shell '${getExe is-vim}' 'send-keys C-k' 'select-pane -U'
        bind-key -n 'C-l' if-shell '${getExe is-vim}' 'send-keys C-l' 'select-pane -R'

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
        {
          plugin = fingers;
          extraConfig = ''
            set -g @fingers-key y
            set -g @fingers-hint-style "fg=green,bold"
            set -g @fingers-highlight-style "fg=yellow"
            set -g @fingers-backdrop-style "dim"
          '';
        }
        {
          plugin = pkgs.internal.tmux-power-zoom;
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
            set -g @sessionx-zoxide-mode '${
              if config.programs.zoxide.enable
              then "on"
              else "off"
            }'
            set -g @sessionx-custom-paths "${config.home.homeDirectory}/development/personal,${config.home.homeDirectory}/development/dragonarmy"
            set -g @sessionx-custom-paths-subdirectories "true"
            set -g @sessionx-bind-kill-session 'alt-x'
          '';
        }
        {
          plugin = pkgs.internal.tmux-theme;
          extraConfig = ''
            set -g @theme_custom_theme_dir "${themesDir}"
            set -g @theme_custom_plugin_dir "${themeModulesDir}"
            set -g @theme_flavour "gruvbox-material"
            set -g status-interval 1

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

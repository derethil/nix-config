{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf types getExe;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.cli.tmux;

  themes = ./themes;
  modules = ./modules;

  is_vim =
    pkgs.writeShellScriptBin "is_vim.sh"
    /*
    bash
    */
    ''
      pane_pid=$(tmux display -p "#{pane_pid}")

      [ -z "$pane_pid" ] && exit 1

      # Retrieve all descendant processes of the tmux pane's shell by iterating through the process tree.
      # This includes child processes and their descendants recursively.
      descendants=$(ps -eo pid=,ppid=,stat= | awk -v pid="$pane_pid" '{
          if ($3 !~ /^T/) {
              pid_array[$1]=$2
          }
      } END {
          for (p in pid_array) {
              current_pid = p
              while (current_pid != "" && current_pid != "0") {
                  if (current_pid == pid) {
                      print p
                      break
                  }
                  current_pid = pid_array[current_pid]
              }
          }
      }')

      if [ -n "$descendants" ]; then

          descendant_pids=$(echo "$descendants" | tr '\n' ',' | sed 's/,$//')

          ps -o args= -p "$descendant_pids" | grep -iqE "(^|/)([gn]?vim?x?)(diff)?"

          if [ $? -eq 0 ]; then
              exit 0
          fi
      fi

      exit 1
    '';
in {
  options.glace.cli.tmux = {
    enable = mkBoolOpt false "Whether to enable Tmux";
    extraVariables = mkOpt (types.listOf types.str) [] "Additional environment variables to refresh in tmux sessions.";
  };

  config = mkIf cfg.enable {
    programs.tmux = {
      package = pkgs.glace.tmux-wrapper.override {inherit config lib;};
      enable = true;
      shell = mkIf (!pkgs.stdenv.isDarwin) "${getExe pkgs.fish}";
      terminal = "tmux-256color";
      prefix = "C-Space";
      keyMode = "vi";
      customPaneNavigationAndResize = true;

      extraConfig = ''
        # Force fish shell on Darwin as it doesn't seem to work with just shell=
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          set-option -g default-shell "${getExe pkgs.fish}"
          set-option -g default-command "${getExe pkgs.fish}"
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

        # Vim navigation keybindings
        bind-key -n 'C-h' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-h' 'select-pane -L'
        bind-key -n 'C-j' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-j' 'select-pane -D'
        bind-key -n 'C-k' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-k' 'select-pane -U'
        bind-key -n 'C-l' if-shell '${is_vim}/bin/is_vim.sh' 'send-keys C-l' 'select-pane -R'

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
      '';

      plugins = with pkgs.tmuxPlugins; [
        sensible
        yank
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

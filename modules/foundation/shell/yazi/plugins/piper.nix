{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.piper = pkgs.yaziPlugins.piper;

      settings.plugin.prepend_previewers = [
        {
          url = "*/";
          run = ''piper -- eza -TL=1 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
        }
        {
          url = "*.csv,*.json";
          run = ''piper -- bat -p --color=always "$1"'';
        }
        {
          url = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
        }
      ];

      extraPackages = with pkgs; [
        eza
        bat
        glow
      ];
    };
  };
}

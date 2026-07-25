{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      extraPackages = with pkgs; [
        bat
        eza
        glow
      ];

      plugins.piper = pkgs.yaziPlugins.piper;

      settings.plugin.prepend_previewers = [
        {
          run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
          url = "*.md";
        }
        {
          run = ''piper -- bat -p --color=always "$1"'';
          url = "*.csv,*.json";
        }
        {
          run = ''piper -- eza -TL=1 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
          url = "*/";
        }
      ];
    };
  };
}

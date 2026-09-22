{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.codex-desktop-linux = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:ilysenko/codex-desktop-linux";
  };

  flake.modules.homeManager.codex-desktop = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.modules.homeManager.codex
      inputs.codex-desktop-linux.homeManagerModules.default
    ];

    config = lib.mkMerge [
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        programs.codexDesktopLinux = {
          enable = true;
          cliPackage = config.programs.codex.package;

          linuxFeatures = [
            # Features
            "appshots"
            "computer-use-linux"
            "remote-control-ui"
            "remote-mobile-control"
            "copilot-reasoning-effort"

            # UI Tweaks and UX enhancements
            "frameless-titlebar"
            "preferred-editor-file-links"

            # Reapers
            "mcp-helper-reaper"
            "node-repl-reaper"
          ];
        };
      })

      (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin {
        home.packages = [pkgs.chatgpt];
      })
    ];
  };
}

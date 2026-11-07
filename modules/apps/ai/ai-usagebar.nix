{inputs, ...}: {
  flake-file.inputs.ai-usagebar = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:akitaonrails/ai-usagebar";
  };

  flake.modules.homeManager.ai-usagebar = {
    config,
    pkgs,
    ...
  }: {
    home.packages = [
      inputs.ai-usagebar.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];

    xdg.configFile."ai-usagebar/config.toml".source = (pkgs.formats.toml {}).generate "ai-usagebar-config.toml" {
      openai.codex_auth_path = "${config.xdg.configHome}/codex/auth.json";
    };
  };
}

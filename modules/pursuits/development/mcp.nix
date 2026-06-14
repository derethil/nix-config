{self, ...}: {
  flake.modules.homeManager.mcp = {
    config,
    pkgs,
    lib,
    ...
  }: let
    inherit (lib) getExe;

    context7 = pkgs.writeShellScript "context7-mcp" ''
      export PATH="${pkgs.nodejs}/bin:$PATH"
      API_KEY=$(cat ${config.sops.secrets."applications/mcp/context7/api_key".path})
      exec npx -y @upstash/context7-mcp --api-key "$API_KEY"
    '';
  in {
    imports = [
      self.modules.homeManager.secrets
    ];

    sops.secrets."applications/mcp/context7/api_key" = {};

    programs.mcp = {
      enable = true;
      servers = {
        nixos.command = getExe pkgs.mcp-nixos;
        context7.command = toString context7;
      };
    };
  };
}

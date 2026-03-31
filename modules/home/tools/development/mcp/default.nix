{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.development.mcp;

  context7-pkg = pkgs.writeShellScript "context7-mcp-wrapper" ''
    export PATH="${pkgs.nodejs}/bin:$PATH"
    API_KEY=$(cat ${config.sops.secrets."applications/mcp/context7/api_key".path})
    exec npx -y @upstash/context7-mcp --api-key "$API_KEY"
  '';
in {
  options.glace.tools.development.mcp = {
    enable = mkBoolOpt false "Whether to enable MCP configurations.";
  };

  config = mkIf cfg.enable {
    # TODO: use claudeCode.enableMcpIntegration and programs.mcp.servers when that option is added
    programs.claude-code.mcpServers = {
      nixos = {
        command = getExe pkgs.mcp-nixos;
      };

      context7 = {
        command = "${context7-pkg}";
      };
    };

    secrets."applications/mcp/context7/api_key" = {};
  };
}

{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.development.mcp;
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
    };
  };
}

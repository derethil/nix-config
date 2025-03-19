{pkgs, ...}: {
  imports = [
  ];

  home.packages = with pkgs; [
    jira-cli-go # Jira CLI

    alejandra # Nix Formatter
    nixfmt-rfc-style
  ];
}

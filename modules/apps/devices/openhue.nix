{
  flake.modules.homeManager.openhue = {
    lib,
    pkgs,
    ...
  }: {
    home.packages = [pkgs.openhue-cli];

    programs.fish.interactiveShellInit = ''
      ${lib.getExe pkgs.openhue-cli} completion fish | source
    '';
  };
}

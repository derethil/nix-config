{
  flake.modules.homeManager.openhue = {
    pkgs,
    lib,
    ...
  }: {
    home.packages = [pkgs.openhue-cli];

    programs.fish.interactiveShellInit = ''
      ${lib.getExe pkgs.openhue-cli} completion fish | source
    '';
  };
}

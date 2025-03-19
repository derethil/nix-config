{pkgs, ...}: {
  imports = [
    ./global
    ./features/cli
  ];
}

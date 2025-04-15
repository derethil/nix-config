{pkgs, ...}: {
  nixGL.packages = pkgs.inputs.nixgl;
  nixGL.defaultWrapper = "nvidia";
}

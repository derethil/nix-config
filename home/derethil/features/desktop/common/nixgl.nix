{inputs, ...}: {
  nixGL.packages = inputs.nixgl.packages;
  nixGL.defaultWrapper = "nvidia";
}

{ config, pkgs, lib, ... }:
{
  options.nixgl.defaultWrapper = lib.mkOption {
    type = lib.types.str;
    default = "";
  };

  config = lib.mkMerge [
    {
      nixGL.packages = pkgs.inputs.nixgl; 
    }
    (lib.mkIf (config.nixgl.defaultWrapper != "") {
      nixGL.defaultWrapper = config.nixgl.defaultWrapper;
    })
  ];
}


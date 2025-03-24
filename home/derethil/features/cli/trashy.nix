{
  inputs,
  pkgs,
  ...
}: {
  home.packages = [inputs.trashy.defaultPackage.${pkgs.system}];
}

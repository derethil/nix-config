{inputs, ...}: {
  perSystem = {pkgs, ...}: {
    formatter = pkgs.writeShellApplication {
      name = "pedantix";
      runtimeInputs = [inputs.pedantix.packages.${pkgs.stdenv.hostPlatform.system}.pedantix-wrapped];
      text = ''exec pedantix --config ${inputs.self}/pedantix.toml "$@"'';
    };
  };
}

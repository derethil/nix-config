{...}: final: prev: {
  linuxPackages = prev.linuxPackages.extend (self: super: {
    it87 = super.it87.overrideAttrs (oldAttrs: {
      name = "it87-unstable-2025-12-04-${self.kernel.version}";
      src = final.fetchFromGitHub {
        owner = "frankcrawford";
        repo = "it87";
        rev = "h2ram-mmio";
        sha256 = "1kv7gf52ci4s6rfa9cn8s9bmxjyibv95znmy3zwf4zg42jshxrfd";
      };
    });
  });
}

{self, ...}: {
  flake.modules = self.factory.user rec {
    name = "derethil";
    passwordSecret = "users/${name}/hashedPassword";
    fullName = "Jaren Glenn";
    email = "jarenglenn@gmail.com";
  };
}

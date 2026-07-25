{self, ...}: {
  flake.modules = self.factory.user rec {
    email = "jarenglenn@gmail.com";
    fullName = "Jaren Glenn";
    name = "derethil";
    passwordSecret = "users/${name}/hashedPassword";
  };
}

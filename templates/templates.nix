{
  flake.templates = {
    python = {
      path = ./_python;
      description = "A template for Python development using devenv and uv";
    };
    npm = {
      path = ./_npm;
      description = "A template for Node.js development using devenv";
    };
    dragonarmy-npm-golang = {
      path = ./_dragonarmy-npm-golang;
      description = "A template for Node.js and Go development using devenv";
    };
  };
}

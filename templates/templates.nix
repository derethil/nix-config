{
  flake.templates = {
    dragonarmy-npm-golang = {
      description = "A template for Node.js and Go development using devenv";
      path = ./_dragonarmy-npm-golang;
    };

    npm = {
      description = "A template for Node.js development using devenv";
      path = ./_npm;
    };

    python = {
      description = "A template for Python development using devenv and uv";
      path = ./_python;
    };

    rust = {
      description = "A template for Rust development using devenv";
      path = ./_rust;
    };
  };
}

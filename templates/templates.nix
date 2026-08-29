{
  flake.templates = {
    fullstack-node-go = {
      description = "A template for Node.js and Go development using devenv";
      path = ./_fullstack-node-go;
    };

    node = {
      description = "A template for Node.js development using devenv";
      path = ./_node;
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

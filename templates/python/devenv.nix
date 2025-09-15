{
  languages = {
    python = {
      enable = true;
      version = "3.13";
      venv.enable = true;
      uv.enable = true;
    };
  };

  enterShell = ''
    echo "Python development environment loaded"
    echo "Python version: $(python --version)"
    echo "uv version: $(uv --version)"
  '';
}

{lib, ...}: {
  # https://github.com/jlowin/fastmcp/issues (anyio cancel-scope tests are flaky under sandboxed builds)
  flake.overlays.fastmcp-flaky-tests = _: prev: {
    pythonPackagesExtensions = lib.flatten [
      prev.pythonPackagesExtensions
      (_: pprev: {
        fastmcp = pprev.fastmcp.overridePythonAttrs {
          doCheck = false;
        };
      })
    ];
  };
}

{
  languages = {
    javascript = {
      enable = true;
      npm.enable = false;
      pnpm.enable = true;
    };
  };

  processes = {
    dev.exec = "pnpm run dev";
  };
}

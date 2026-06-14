{
  self,
  lib,
  ...
}: let
  aliases = {
    d = "diff -M";
    a = "add";
    f = "fetch";
    aa = "add --all .";
    bd = "branch -D";
    r = "restore";
    rs = "restore --staged";
    bl = "branch --list";
    s = "status";
    ca = "commit --amend --no-edit";
    m = "merge --no-ff";
    pt = "push --tags";
    P = "push";
    p = "pull";
    pr = "pull --rebase";
    pf = "push --force-with-lease";
    rh = "reset --hard";
    b = "branch";
    cob = "checkout -b";
    co = "checkout";
    ba = "branch -a";
    cp = "cherry-pick";
    l = "log --pretty=format:'%Cgreen%h%Creset - %Cblue%an%Creset @ %ar : %s%C(yellow)%d%Creset'";
    l2 = "log --pretty='format:%Cgreen%h%Creset %an - %s%C(yellow)%d%Creset' --graph";
    lv = "log --stat";
    pom = "pull origin master";
    cf = "clean -fd";
    cod = "checkout -- .";
    pum = "pull upstream master";
    pod = "push origin --delete";
    su = "status -uno";
    cm = "commit -m";
    cv = "commit --verbose";
    cn = "commit --amend --no-edit";
    c = "commit --verbose";
    rm = "reset HEAD";
    t = "log --tags --simplify-by-decoration --pretty='format:%ai %d'";
    sl = "shortlog -s -n --all --no-merges";
    op = "open";
    w = "switch";
    ri = "rebase --interactive";
    rc = "rebase --continue";
    rk = "rebase --skip";
    ra = "rebase --abort";
  };

  abbreviations = builtins.listToAttrs (map
    (name: {
      name = "g" + name;
      value = "git ${aliases.${name}}";
    })
    (builtins.attrNames aliases));
in {
  flake.modules.homeManager.git = {
    config,
    pkgs,
    ...
  }: let
    pkg =
      if pkgs.stdenv.isDarwin
      then pkgs.git
      else pkgs.git.override {withLibsecret = true;};

    git-fixup = pkgs.callPackage ./_packages/git-fixup.nix {};
    git-prune-merged = pkgs.callPackage ./_packages/git-prune-merged.nix {};

    credentialHelper =
      if pkgs.stdenv.isDarwin
      then "osxkeychain"
      else "libsecret";
  in {
    imports = [
      self.modules.homeManager.shell-consumer
      self.modules.generic.user-options
    ];

    shell = {
      abbreviations =
        {
          gfu = "git-fixup ";
          gpm = "git-prune-merged ";
        }
        // abbreviations;
      aliases.gcd = ''cd "$(git rev-parse --show-toplevel)"'';
    };

    home.packages = [
      git-fixup
      git-prune-merged
      pkgs.git-open
      pkgs.gh
    ];

    programs.git = {
      enable = true;
      package = pkg;
      lfs = {
        enable = true;
      };
      settings = {
        alias = aliases;
        user = {
          name = config.internal.user.fullName;
          email = lib.mkDefault config.internal.user.email;
        };
        init = {
          defaultBranch = "main";
        };
        core = {
          editor = "nvim";
          hooksPath = ".githooks";
        };
        credential = {
          helper = credentialHelper;
        };
        push = {
          autoSetupRemote = true;
        };
        pull = {
          ff = "only";
        };
      };
      includes = [
        {
          condition = "gitdir:~/development/dragonarmy/**/*";
          contents.user.email = "jaren.glenn@df-nn.com";
        }
      ];
      ignores = [
        ".venv"
        ".envrc"
        ".nvim.lua"
        ".direnv/"
        ".python-version"
        ".typos.toml"
        "**/.golangci.yml"
        "CLAUDE.md"
        ".claude/"
        ".devenv*"
        "devenv.nix"
        "devenv.yaml"
        "devenv.lock"
      ];
    };

    programs.diff-so-fancy = {
      enable = true;
      enableGitIntegration = true;
    };
  };
}

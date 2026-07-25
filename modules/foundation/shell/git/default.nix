{
  self,
  lib,
  ...
}: let
  aliases = {
    P = "push";
    a = "add";
    aa = "add --all .";
    b = "branch";
    ba = "branch -a";
    bd = "branch -D";
    bl = "branch --list";
    c = "commit --verbose";
    ca = "commit --amend --no-edit";
    cf = "clean -fd";
    cm = "commit -m";
    cn = "commit --amend --no-edit";
    co = "checkout";
    cob = "checkout -b";
    cod = "checkout -- .";
    cp = "cherry-pick";
    cv = "commit --verbose";
    d = "diff -M";
    f = "fetch";
    l = "log --pretty=format:'%Cgreen%h%Creset - %Cblue%an%Creset @ %ar : %s%C(yellow)%d%Creset'";
    l2 = "log --pretty='format:%Cgreen%h%Creset %an - %s%C(yellow)%d%Creset' --graph";
    lv = "log --stat";
    m = "merge --no-ff";
    op = "open";
    p = "pull";
    pf = "push --force-with-lease";
    pod = "push origin --delete";
    pom = "pull origin master";
    pr = "pull --rebase";
    pt = "push --tags";
    pum = "pull upstream master";
    r = "restore";
    ra = "rebase --abort";
    rc = "rebase --continue";
    rh = "reset --hard";
    ri = "rebase --interactive";
    rk = "rebase --skip";
    rm = "reset HEAD";
    rs = "restore --staged";
    s = "status";
    sl = "shortlog -s -n --all --no-merges";
    su = "status -uno";
    t = "log --tags --simplify-by-decoration --pretty='format:%ai %d'";
    w = "switch";
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
      self.modules.generic.user-options
      self.modules.homeManager.shell-consumer
    ];

    home.packages = [
      git-fixup
      git-prune-merged
      pkgs.gh
      pkgs.git-open
    ];

    programs = {
      diff-so-fancy = {
        enable = true;
        enableGitIntegration = true;
      };

      git = {
        enable = true;
        package = pkg;

        ignores = [
          "**/.golangci.yml"
          ".claude/"
          ".devenv*"
          ".direnv/"
          ".envrc"
          ".nvim.lua"
          ".python-version"
          ".typos.toml"
          ".venv"
          "CLAUDE.md"
          "devenv.lock"
          "devenv.nix"
          "devenv.yaml"
        ];

        includes = [
          {
            condition = "gitdir:~/development/dragonarmy/**/*";
            contents.user.email = "jaren.glenn@df-nn.com";
          }
        ];

        lfs.enable = true;

        settings = {
          alias = aliases;

          core = {
            editor = "nvim";
            hooksPath = ".githooks";
          };

          credential.helper = credentialHelper;
          init.defaultBranch = "main";
          pull.ff = "only";
          push.autoSetupRemote = true;

          user = {
            email = lib.mkDefault config.internal.user.email;
            name = config.internal.user.fullName;
          };
        };
      };
    };

    shell = {
      abbreviations =
        {
          gfu = "git-fixup ";
          gpm = "git-prune-merged ";
        }
        // abbreviations;

      aliases.gcd = ''cd "$(git rev-parse --show-toplevel)"'';
    };
  };
}

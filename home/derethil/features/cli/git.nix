{
  pkgs,
  lib,
  config,
  ...
}: let
  # git commit --amend, but for older commits
  git-fixup = pkgs.writeShellScriptBin "gfu" ''
    rev="$(git rev-parse "$1")"
    git commit --fixup "$@"
    GIT_SEQUENCE_EDITOR=true git rebase -i --autostash --autosquash $rev^
  '';

  # go to the root of the git repository
  git-root = pkgs.writeShellScriptBin "gcd" ''
    path=$(git rev-parse --show-toplevel)
    cd $path
  '';

  # remove branches that have been merged
  git-prune-merged = pkgs.writeShellScriptBin "gpr" ''
    if [ $# -ne 1 ]; then
      echo "Usage: gpr <branch>"
      exit 1
    fi

    branch="$1"

    if ! git rev-parse --verify "$branch" >/dev/null 2>&1; then
      echo "Branch '$branch' does not exist"
      exit 1
    fi

    if [ -z "$(git branch --merged="$branch")" ]; then
      echo "No branches to prune"
      exit 1
    fi

    git branch --merged="$branch" | grep -v "$branch" | xargs -n 1 git branch -d
    git fetch --prune;
  '';

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
    ca = "commit -a -m";
    m = "merge --no-ff";
    pt = "push --tags";
    P = "push";
    p = "pull";
    pf = "push --force-with-lease";
    rh = "reset --hard";
    b = "branch";
    cob = "checkout -b";
    co = "checkout";
    ba = "branch -a";
    cp = "cherry-pick";
    l = "log --pretty=format:'%Cgreen%h%Creset - %Cblue%an%Creset @ %ar : %s'";
    l2 = "log --pretty='format:%Cgreen%h%Creset %an - %s' --graph";
    lv = "log --stat";
    pom = "pull origin master";
    gcd = "";
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
  };

  shellAbbrs = builtins.listToAttrs (map
    (name: {
      name = "g" + name;
      value = "git ${aliases.${name}}";
    })
    (builtins.attrNames aliases));
in {
  home.packages = [git-fixup git-root git-prune-merged];

  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;

    userName = "Jaren Glenn";
    userEmail = lib.mkDefault "jarenglenn@gmail.com";
    diff-so-fancy.enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";
      core.editor = "nvim";
      credential.helper = "cache --timeout=3600";
      push.autoSetupremote = true;
      pull.ff = "only";
    };

    aliases = aliases;

    ignores = [
      ".venv"
      ".tool-versions"
      ".envrc"
      ".local/"
      ".nvim.lua"
      ".vscode/"
      ".lazy.lua"
      "**/*.local"
      "*.local.*"
      ".direnv/"
      ".python-version"
      ".typos.toml"
    ];
  };

  programs.fish.shellAbbrs = lib.mkIf config.programs.fish.enable shellAbbrs;
}

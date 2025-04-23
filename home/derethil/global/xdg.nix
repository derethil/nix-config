{
  home.sessionVariables = rec {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
    XDG_BIN_HOME = "$HOME/.local/bin";

    # ASDF
    ASDF_CONFIG_FILE = "${XDG_CONFIG_HOME}/asdf/asdfrc";
    ASDF_DATA_DIR = "${XDG_DATA_HOME}/asdf";

    # AWS CLI
    AWS_SHARED_CREDENTIALS_FILE = "${XDG_CONFIG_HOME}/aws/credentials";
    AWS_CONFIG_FILE = "${XDG_CONFIG_HOME}/aws/config";

    # Bun
    BUN_INSTALL = "${XDG_DATA_HOME}/bun";

    # Ruby Bundle
    BUNDLE_USER_CACHE = "${XDG_CACHE_HOME}/bundle";
    BUNDLE_USER_CONFIG = "${XDG_CONFIG_HOME}/bundle/config";
    BUNDLE_USER_PLUGIN = "${XDG_DATA_HOME}/bundle";

    # Cargo / Rust
    CARGO_HOME = "${XDG_DATA_HOME}/cargo";
    RUSTUP_HOME = "${XDG_DATA_HOME}/rustup";

    # Cuda
    CUDA_CACHE_PATH = "${XDG_CACHE_HOME}/nv";

    # Docker
    DOCKER_CONFIG = "${XDG_CONFIG_HOME}/docker";

    # Dotnet
    DOTNET_CLI_HOME = "${XDG_DATA_HOME}/dotnet";

    # GnuPG is commented out in your Fish config, so keeping it commented here
    # GNUPGHOME = "${XDG_DATA_HOME}/gnupg";

    # Golang
    GOMODCACHE = "${XDG_CACHE_HOME}/go-mod";
    GOPATH = "${XDG_DATA_HOME}/go";

    # Gradle / Java
    GRADLE_USER = "${XDG_DATA_HOME}/gradle";
    __JAVA_OPTIONS = "-Djava.util.prefs.userRoot ${XDG_CONFIG_HOME}/java";
    JAVA_HOME = "/usr/lib/jvm/default";

    # Histfile
    HISTFILE = "${XDG_DATA_HOME}/bash/history";

    # IRB
    IRBRC = "${XDG_CONFIG_HOME}/irb/irbrc";

    # NPM / PNPM
    NPM_CONFIG_USERCONFIG = "${XDG_CONFIG_HOME}/npm/npmrc";
    PNPM_HOME = "${XDG_DATA_HOME}/pnpm";

    # NuGet
    NUGET_PACKAGES = "${XDG_CACHE_HOME}/NuGetPackages";

    # Password Store
    PASSWORD_STORE_DIR = "${XDG_DATA_HOME}/pass";

    # Python / Pip
    PYTHON_HISTORY = "${XDG_DATA_HOME}/python/history";

    # Wine
    WINEPREFIX = "${XDG_DATA_HOME}/wine";
  };
}

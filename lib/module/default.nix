{lib, ...}:
with lib; rec {
  # MkOpt

  ## Create a NixOS module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

  # mkSubmoduleOpt

  ## Create a NixOS submodule option without a description.
  ##
  ## ```nix
  ## lib.mkSubmoduleOpt' { options = { ... }; }
  ## ```
  ##
  #@ Submodule -> Any
  mkSubmoduleOpt' = options: mkOpt (types.submodule {inherit options;}) null null;

  ## Create a NixOS submodule option.
  ##
  ## ```nix
  ## lib.mkSubmoduleOpt { inherit description; options = { ... }; }
  ## ```
  ##
  #@ Submodule -> String -> Any
  mkSubmoduleOpt = description: options: mkOpt (types.submodule {inherit options;}) null description;

  # mkNullableOpt

  ## Create a nullable NixOS module option.
  ##
  ## ```nix
  ## lib.mkNullableOpt nixpkgs.lib.types.nullOr nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkNullableOpt = type: default: description:
    mkOpt (types.nullOr type) default description;

  ## Create a nullable NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkNullableOpt' nixpkgs.lib.types.nullOr nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkNullableOpt' = type: default: mkOpt (types.nullOr type) default null;

  # mkBoolOpt

  ## Create a boolean NixOS module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a boolean NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;

  # Enable/Disable Helpers

  enabled = {
    ## Quickly enable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ true
    enable = true;
  };

  disabled = {
    ## Quickly disable an option.
    ##
    ## ```nix
    ## services.nginx = enabled;
    ## ```
    ##
    #@ false
    enable = false;
  };
}

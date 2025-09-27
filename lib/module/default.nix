{lib, ...}:
with lib; rec {
  ## MkOpt

  ## Create a Nix module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  ## Create a Nix module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

  ## mkNullableOpt

  ## Create a nullable Nix module option.
  ##
  ## ```nix
  ## lib.mkNullableOpt lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkNullableOpt = type: default: description:
    mkOpt (types.nullOr type) default description;

  ## Create a nullable Nix module option without a description.
  ##
  ## ```nix
  ## lib.mkNullableOpt' lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkNullableOpt' = type: default: mkOpt (types.nullOr type) default null;

  ## mkSubmoduleListOpt

  ## Create a submodule list Nix option without a description.
  ##
  ## ```nix
  ## lib.mkSubmoduleListOpt' { ... };
  ## ```
  ##
  ## Options
  mkSubmoduleListOpt' = options:
    mkOpt (types.listOf (types.submodule {inherit options;})) [] null;

  ## Create a submodule list Nix option with a description.
  ##
  ## ```nix
  ## lib.mkSubmoduleListOpt "Description of my option." { ... };
  ## ```
  ##
  ## String -> Options
  mkSubmoduleListOpt = description: options:
    mkOpt (types.listOf (types.submodule {inherit options;})) [] description;

  ## mkBoolOpt

  ## Create a boolean Nix module option.
  ##
  ## ```nix
  ## lib.mkBoolOpt true "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt = mkOpt types.bool;

  ## Create a boolean Nix module option without a description.
  ##
  ## ```nix
  ## lib.mkBoolOpt true
  ## ```
  ##
  #@ Type -> Any -> String
  mkBoolOpt' = mkOpt' types.bool;

  ## Enable/Disable Helpers

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

  ## Create an enabled attrset with additional options merged in.
  ##
  ## ```nix
  ## services.nginx = enabled' { workers = 4; };
  ## ```
  ##
  #@ AttrSet -> AttrSet
  enabled' = attrs: attrs // enabled;

  ## Create a disabled attrset with additional options merged in.
  ##
  ## ```nix
  ## services.nginx = disabled' { workers = 2; };
  ## ```
  ##
  #@ AttrSet -> AttrSet
  disabled' = attrs: attrs // disabled;

  ## mkPackageOpt

  ## Create a nullable package option with null default.
  ##
  ## ```nix
  ## lib.mkPackageOpt "Web browser package to use."
  ## ```
  ##
  #@ Package -> String -> Option
  mkPackageOpt = package: description:
    mkNullableOpt types.package package description;

  ## Create a nullable package option without a description.
  ##
  ## ```nix
  ## lib.mkPackageOpt'
  ## ```
  ##
  #@ Package -> Option
  mkPackageOpt' = package: mkNullableOpt types.package package null;
}

{lib, ...}:
with lib; rec {
  ## Create a NixOS module option.
  ##
  ## ```nix
  ## lib.mkOpt nixpkgs.lib.types.str "My default" "Description of my option."
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt = type: default: description:
    mkOption {inherit type default description;};

  ## Create a submodule option for a NixOS module.
  ## This function simplifies the creation of submodule options by combining the `mkOpt'` function
  ## with the `types.submodule` type. It accepts a table of submodule options and creates a
  ## corresponding option with a `null` default value.
  ##
  ## Example usage:
  ## ```nix
  ## lib.mkSubmoduleOpt {
  ##   option1 = mkBoolOpt true "Enable option1.";
  ##   option2 = mkOpt types.str "default" "Description of option2.";
  ## }
  ## ```
  ##
  ## @Options -> Any
  mkSubmoduleOpt = options: mkOpt' (types.submodule {inherit options;}) null;

  ## Create a NixOS module option without a description.
  ##
  ## ```nix
  ## lib.mkOpt' nixpkgs.lib.types.str "My default"
  ## ```
  ##
  #@ Type -> Any -> String
  mkOpt' = type: default: mkOpt type default null;

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

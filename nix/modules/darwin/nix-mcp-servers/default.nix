{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  pkgs,
  # You also have access to your flake's inputs.
  inputs,
  # Additional metadata is provided by Snowfall Lib.
  namespace, # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`).
  target, # The Snowfall Lib target for this system (eg. `x86_64-iso`).
  format, # A normalized name for the system target (eg. `iso`).
  virtual, # A boolean to determine whether this system is a virtual target using nixos-generators.
  systems, # An attribute map of your defined hosts.
  # All other arguments come from the module system.
  config,
  ...
}: {
  # config.${namespace}.default

  _file = ./default.nix;

  # Make all our library functions available to modules
  config._module.args.lib = lib.extend (self: super: {
    ${namespace} = import ../../../lib {
      lib = super;
      inherit inputs;
      snowfall-inputs = inputs;
    };
  });

  imports = [
    ./clients
    ./servers
  ];

  options.${namespace} = with lib.types; {
    configPath = lib.mkOption {
      type = str;
      description = "Path where to store MCP configuration files";
      default = "${config.users.users.${config.users.primaryUser}.home}/Library/Application Support/mcp";
    };
  };

  config = {
    # This ensures the MCP directory exists
    system.activationScripts.postUserActivation.text = ''
      mkdir -p "${config.${namespace}.configPath}"
    '';
  };
}

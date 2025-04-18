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
}: let
  cfg = config.${namespace}.clients;
in {
  # config.${namespace}.clients.default

  imports = [
    ./cursor
    ./claude
  ];

  options.${namespace}.clients = with lib.types; {
    generateConfigs = lib.mkOption {
      type = bool;
      description = "Whether to generate MCP configuration files";
      default = true;
    };
  };

  # Clean up config files for disabled clients
  config = {
    # Handle client configuration files
    home.file = lib.mkMerge [
      # Remove Claude config file if disabled
      (lib.mkIf (!cfg.claude.enable && cfg.generateConfigs) {
        "${cfg.claude.configPath}" = lib.mkIf (cfg.claude.configPath != null) {
          text = "";
          source = null;
          enable = false;
        };
      })

      # Remove Cursor config file if disabled
      (lib.mkIf (!cfg.cursor.enable && cfg.generateConfigs) {
        "${cfg.cursor.configPath}" = lib.mkIf (cfg.cursor.configPath != null) {
          text = "";
          source = null;
          enable = false;
        };
      })
    ];
  };
}

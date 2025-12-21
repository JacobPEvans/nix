# File Type Associations for macOS
#
# Configure custom file extension mappings and default applications.
# Uses duti to register file type handlers with Launch Services.
#
# This module enables macOS to recognize non-standard archive extensions
# (like .spl and .crbl) as compressed tar archives, enabling:
# - Double-click extraction in Finder
# - Proper file type detection
# - Shell autocomplete suggestions
#
# Reference: https://github.com/moretension/duti

{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.system.fileAssociations;

  # Convert extension mapping to duti command
  # Example: { extension = "spl"; handler = "com.apple.archiveutility"; } -> duti command
  associationToDutiCommand =
    assoc:
    let
      role = "all"; # all = viewer, editor, and shell role
    in
    ''${pkgs.duti}/bin/duti -s ${escapeShellArg assoc.handler} ${escapeShellArg ".${assoc.extension}"} ${escapeShellArg role}'';

  # Generate activation script for all file associations
  activationScript = ''
    echo "Configuring file type associations..." >&2
    set -e  # Exit on any command failure
    ${concatMapStringsSep "\n" associationToDutiCommand cfg.customExtensions}
    set +e  # Re-enable error tolerance for Finder restart

    # Restart Finder to apply changes immediately
    # (Launch Services database updates may not be visible until restart)
    /usr/bin/killall Finder 2>/dev/null || true
  '';

in
{
  # ==========================================================================
  # Module Options
  # ==========================================================================
  options.system.fileAssociations = {
    enable = mkEnableOption "custom file type associations" // {
      default = true;
    };

    customExtensions = mkOption {
      type = types.listOf (
        types.submodule {
          options = {
            extension = mkOption {
              # Restrict to reasonable filename extension characters and disallow leading dots
              type = types.strMatching "^[A-Za-z0-9][A-Za-z0-9._-]*$";
              description = "File extension (without leading dot)";
              example = "spl";
            };

            handler = mkOption {
              type = types.str;
              description = "Bundle identifier for the handler application";
              example = "com.apple.archiveutility";
            };

            description = mkOption {
              type = types.str;
              default = "";
              description = "Human-readable description of the file type";
              example = "Splunk archive";
            };
          };
        }
      );

      default = [
        {
          extension = "spl";
          handler = "com.apple.archiveutility";
          description = "Splunk archive (tar.gz)";
        }
        {
          extension = "crbl";
          handler = "com.apple.archiveutility";
          description = "CRBL archive (tar.gz)";
        }
      ];

      description = ''
        List of custom file extensions to associate with specific application handlers.

        Each extension will be registered with macOS Launch Services to enable:
        - Double-click opening with the specified application
        - Proper file type detection
        - Shell autocomplete suggestions

        Common bundle identifiers for macOS applications:
        - com.apple.archiveutility (Archive Utility for archives)
        - com.apple.TextEdit (TextEdit for text files)
        - com.apple.Preview (Preview for PDFs and images)

        To find bundle IDs for existing file types:
          duti -x <extension>
        To find bundle IDs for installed applications:
          osascript -e 'id of app "<Application Name>"'
      '';

      example = literalExpression ''
        [
          {
            extension = "spl";
            handler = "com.apple.archiveutility";
            description = "Splunk archive";
          }
          {
            extension = "myarchive";
            handler = "com.apple.archiveutility";
            description = "My custom archive format";
          }
        ]
      '';
    };
  };

  # ==========================================================================
  # Module Implementation
  # ==========================================================================
  config = mkIf cfg.enable {
    # Add duti package for file association management
    environment.systemPackages = [ pkgs.duti ];

    # Register file associations on system activation
    # This runs when: darwin-rebuild switch/activate
    system.activationScripts.fileAssociations.text = activationScript;

    # User instructions displayed after rebuild
    system.activationScripts.postActivation.text = mkAfter ''
      echo "" >&2
      echo "File associations configured for:" >&2
      ${concatMapStringsSep "\n" (
        assoc:
        ''echo "  - .${assoc.extension} → ${assoc.handler}${
          optionalString (assoc.description != "") " (${assoc.description})"
        }" >&2''
      ) cfg.customExtensions}
      echo "" >&2
      echo "To verify associations, run:" >&2
      echo "  duti -x <extension>" >&2
      echo "" >&2
      echo "Example:" >&2
      echo "  duti -x spl" >&2
      echo "" >&2
    '';
  };
}

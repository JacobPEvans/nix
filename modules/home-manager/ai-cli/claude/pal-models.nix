# PAL MCP — Dynamic Ollama Model Discovery
#
# Generates ~/.config/pal-mcp/custom_models.json from `ollama list` at
# activation time (darwin-rebuild switch) and injects CUSTOM_MODELS_CONFIG_PATH
# into the PAL server env.
#
# Model registry is rebuilt on every rebuild and can be refreshed between
# rebuilds with: sync-ollama-models
#
# The colon alias trick:
#   PAL's parse_model_option() strips ":tag" before registry lookup, so a
#   model like "glm-5:cloud" must be registered with alias "glm-5". When the
#   user asks for "glm-5", PAL finds the alias → resolves to "glm-5:cloud" →
#   sends that to Ollama. This is handled automatically by the generator script.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.claude;
  outputDir = "${config.home.homeDirectory}/.config/pal-mcp";
  outputFile = "${outputDir}/custom_models.json";
in
{
  config = lib.mkIf cfg.enable {
    # Inject CUSTOM_MODELS_CONFIG_PATH into PAL server env.
    # Merges with the env block defined in mcp/default.nix (DISABLED_TOOLS, etc.).
    programs.claude.mcpServers.pal.env.CUSTOM_MODELS_CONFIG_PATH = outputFile;

    # Generate custom_models.json from `ollama list` during darwin-rebuild switch.
    # If Ollama is unreachable the existing file is kept and no error is raised.
    home.activation.palCustomModels = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      OLLAMA_BIN="${pkgs.ollama}/bin/ollama"
      OUTPUT_FILE="${outputFile}"
      JQ_BIN="${pkgs.jq}/bin/jq"
      export PATH="${
        lib.makeBinPath [
          pkgs.coreutils
          pkgs.gawk
          pkgs.gnused
          pkgs.gnugrep
        ]
      }:$PATH"
      . ${../mcp/scripts/generate-pal-models.sh}
    '';
  };
}

# AI Model Volumes Configuration Module (Darwin)
#
# Manages dedicated APFS volumes for AI model storage:
# - OllamaModels: dedicated volume for Ollama model files
# - HuggingFaceModels: dedicated volume for HuggingFace model files
#
# Usage:
#   programs.ai-volumes = {
#     enable = true;
#     apfsContainer = "disk3";  # Find with: diskutil apfs list
#     ollamaVolume = {
#       enable = true;          # default: true
#       name = "OllamaModels";  # default
#       quota = "500g";         # default
#     };
#     huggingfaceVolume = {
#       enable = true;              # default: true
#       name = "HuggingFaceModels"; # default
#       quota = "400g";             # default
#     };
#   };
#
# Why separate volumes?
# - AI models can be very large (tens to hundreds of GB)
# - Dedicated APFS volumes provide clear disk space visibility
# - APFS quotas prevent runaway disk usage
# - Volumes share container space dynamically (no wasted pre-allocation)

{
  lib,
  config,
  ...
}:

let
  cfg = config.programs.ai-volumes;
  volumeScript = ./scripts/ensure-apfs-volume.sh;
in
{
  options.programs.ai-volumes = {
    enable = lib.mkEnableOption "dedicated APFS volumes for AI models";

    apfsContainer = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = ''
        APFS container identifier where the volumes will be created.
        Find yours with: diskutil apfs list
        Usually "disk3" on Apple Silicon Macs with single internal storage.
      '';
      example = "disk3";
    };

    ollamaVolume = {
      enable = lib.mkEnableOption "Ollama models volume" // {
        default = true;
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "OllamaModels";
        description = "Name of the APFS volume for Ollama model storage.";
      };

      quota = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "500g";
        description = "Optional APFS quota for the Ollama models volume (e.g., \"500g\").";
        example = "500g";
      };
    };

    huggingfaceVolume = {
      enable = lib.mkEnableOption "HuggingFace models volume" // {
        default = true;
      };

      name = lib.mkOption {
        type = lib.types.str;
        default = "HuggingFaceModels";
        description = "Name of the APFS volume for HuggingFace model storage.";
      };

      quota = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = "400g";
        description = "Optional APFS quota for the HuggingFace models volume (e.g., \"400g\").";
        example = "400g";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Validate apfsContainer is set
    assertions = [
      {
        assertion = cfg.apfsContainer != "";
        message = "programs.ai-volumes.apfsContainer must be set. Find yours with: diskutil apfs list";
      }
    ];

    launchd.daemons = lib.mkMerge [
      # Ollama models volume daemon
      (lib.mkIf cfg.ollamaVolume.enable {
        ai-volumes-ollama = {
          serviceConfig = {
            Label = "com.nix-darwin.ai-volumes-ollama";
            ProgramArguments = [
              "/bin/bash"
              "${volumeScript}"
              cfg.ollamaVolume.name
              cfg.apfsContainer
            ]
            ++ lib.optional (cfg.ollamaVolume.quota != null) cfg.ollamaVolume.quota;
            RunAtLoad = true;
            LaunchOnlyOnce = true;
            UserName = "root";
            GroupName = "wheel";
            StandardOutPath = "/var/log/ai-volumes-ollama.log";
            StandardErrorPath = "/var/log/ai-volumes-ollama.log";
          };
        };
      })

      # HuggingFace models volume daemon
      (lib.mkIf cfg.huggingfaceVolume.enable {
        ai-volumes-huggingface = {
          serviceConfig = {
            Label = "com.nix-darwin.ai-volumes-huggingface";
            ProgramArguments = [
              "/bin/bash"
              "${volumeScript}"
              cfg.huggingfaceVolume.name
              cfg.apfsContainer
            ]
            ++ lib.optional (cfg.huggingfaceVolume.quota != null) cfg.huggingfaceVolume.quota;
            RunAtLoad = true;
            LaunchOnlyOnce = true;
            UserName = "root";
            GroupName = "wheel";
            StandardOutPath = "/var/log/ai-volumes-huggingface.log";
            StandardErrorPath = "/var/log/ai-volumes-huggingface.log";
          };
        };
      })
    ];
  };
}

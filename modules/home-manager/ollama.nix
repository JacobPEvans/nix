{
  config,
  lib,
  pkgs,
  ...
}:
#
# Ollama Configuration Module
#
# Manages Ollama LLM runtime environment variables and settings.
# Models are stored on dedicated APFS volume: /Volumes/Ollama/models
#
# Environment variables: https://github.com/ollama/ollama/blob/main/docs/faq.md#how-do-i-configure-ollama-server
#
let
  userConfig = import ../../lib/user-config.nix;
in
{
  # ============================================================================
  # Ollama Environment Variables
  # ============================================================================

  home.sessionVariables = {
    # ========================================================================
    # Model Storage
    # ========================================================================
    # Location where Ollama stores downloaded models
    # Default: ~/.ollama/models
    # Current: /Volumes/Ollama/models (692GB+ on dedicated APFS volume)
    OLLAMA_MODELS = "/Volumes/Ollama/models";

    # ========================================================================
    # Performance & Memory Settings
    # ========================================================================

    # Context window size (tokens)
    # Default: 2048
    # Higher values allow longer conversations but use more memory
    # Popular values: 4096, 8192, 16384, 32768
    OLLAMA_CONTEXT_LENGTH = "8192";

    # How long to keep models loaded in memory after last use
    # Default: 5m
    # Format: duration (e.g., "30s", "5m", "1h", "24h", "-1" for infinite)
    # "-1" keeps models always loaded (faster subsequent requests, more memory)
    OLLAMA_KEEP_ALIVE = "1h";

    # Maximum number of parallel model requests
    # Default: 1 (sequential processing)
    # Higher values allow concurrent requests but increase memory usage
    # Popular values: 1, 2, 4
    # OLLAMA_MAX_QUEUE = "1";

    # Number of layers to offload to GPU
    # Default: -1 (all layers if GPU available)
    # Set to 0 to disable GPU, or specific number for partial offload
    # OLLAMA_NUM_GPU = "-1";

    # Number of threads for CPU computation
    # Default: auto-detected (usually CPU core count)
    # OLLAMA_NUM_THREADS = "8";

    # ========================================================================
    # Network & API Settings
    # ========================================================================

    # Host and port for Ollama API server
    # Default: 127.0.0.1:11434
    # Format: "host:port" or ":port" for all interfaces
    # Examples: "127.0.0.1:11434", "0.0.0.0:11434", ":11434"
    # OLLAMA_HOST = "127.0.0.1:11434";

    # Allowed CORS origins for API requests
    # Default: not set (localhost only)
    # Examples: "*" (all), "http://localhost:*", "https://example.com"
    # OLLAMA_ORIGINS = "*";

    # Enable debug logging
    # Default: not set (info level)
    # Set to "1" or "true" for verbose debugging
    # OLLAMA_DEBUG = "0";

    # ========================================================================
    # Advanced Settings
    # ========================================================================

    # Directory for temporary files during model loading
    # Default: system temp directory
    # OLLAMA_TMPDIR = "/tmp/ollama";

    # Flash attention
    # Default: auto-detected
    # Set to "1" to force enable, "0" to disable
    # OLLAMA_FLASH_ATTENTION = "1";

    # KV cache type
    # Default: "f16" (float16)
    # Options: "f32" (float32), "f16" (float16), "q8_0", "q4_0"
    # Lower precision uses less memory but may reduce quality
    # OLLAMA_KV_CACHE_TYPE = "f16";

    # Runner directory (model execution binaries)
    # Default: ~/.ollama/runners
    # OLLAMA_RUNNERS_DIR = "${config.home.homeDirectory}/.ollama/runners";

    # Disable model file verification
    # Default: not set (verification enabled)
    # Set to "1" to skip SHA256 verification (faster but less safe)
    # OLLAMA_NOPRUNE = "0";

    # ========================================================================
    # Metal (Apple Silicon) Specific
    # ========================================================================

    # Metal GPU selection (macOS only)
    # Default: auto-selected
    # Set to specific GPU index if multiple GPUs
    # OLLAMA_METAL_GPU = "0";
  };

  # ============================================================================
  # SSH Keys for Remote Ollama (if used)
  # ============================================================================
  # Preserve existing SSH keys in ~/.ollama/
  # These are NOT managed by Nix - kept as-is from manual setup
  # Files: ~/.ollama/id_ed25519, ~/.ollama/id_ed25519.pub

  # ============================================================================
  # Symlink Configuration
  # ============================================================================
  # Models directory symlink is managed in hosts/macbook-m4/home.nix
  # home.file.".ollama/models".source = config.lib.file.mkOutOfStoreSymlink "/Volumes/Ollama/models";

  # ============================================================================
  # Notes
  # ============================================================================
  # - Models stay on /Volumes/Ollama (692GB+, symlinked via home-manager)
  # - Database: ~/Library/Application Support/Ollama/db.sqlite (not managed by Nix)
  # - History: ~/.ollama/history (not managed by Nix)
  # - Nixpkgs version: 0.13.2 (replaces manual 0.12.10 install)
  # - For Ollama.app GUI: can coexist with Nix CLI (menu bar, daemon management)
  # - CLI binary from Nix will take precedence in PATH
}

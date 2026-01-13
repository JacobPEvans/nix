# MCP Servers Configuration - Nix-Native
#
# Strategy: Avoid runtime npm/npx/bunx entirely
# All MCP servers are either:
# 1. Native nixpkgs packages (terraform-mcp-server, github-mcp-server, etc.)
# 2. Fetched and cached from GitHub (official MCP servers from modelcontextprotocol)
#
# No runtime dependency installation - everything is deterministic and cached.
#
# Official MCP Servers: https://github.com/modelcontextprotocol/servers

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # Helper to create MCP server config entry
  mkServer =
    {
      enabled ? false,
      command,
      args ? [ ],
      env ? { },
    }:
    {
      inherit command args env;
    }
    // lib.optionalAttrs (!enabled) { enable = false; }
    // lib.optionalAttrs enabled { enable = true; };

  # Helper to fetch MCP server from official modelcontextprotocol repo
  # This is Anthropic's official MCP servers repository
  officialServer =
    {
      name,
      hash,
    }:
    mkServer {
      command = "${pkgs.nodejs}/bin/node";
      args = [
        "${
          pkgs.fetchFromGitHub {
            owner = "modelcontextprotocol";
            repo = "servers";
            rev = "main";
            sparseCheckout = [ "src/${name}" ];
            sha256 = hash;
          }
        }/src/${name}/dist/index.js"
      ];
    };

in
{
  # Export mcpServers for use in claude-config.nix
  # These are then merged into the programs.claude.mcpServers setting
  mcpServers = {
    # ================================================================
    # Official Anthropic MCP Servers (modelcontextprotocol/servers)
    # ALL enabled by default
    # ================================================================

    # Everything - Reference/test server with prompts, resources, and tools
    everything =
      (officialServer {
        name = "everything";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Fetch - Web content fetching and conversion for efficient LLM usage
    fetch =
      (officialServer {
        name = "fetch";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Filesystem - Secure file operations with configurable access controls
    filesystem =
      (officialServer {
        name = "filesystem";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Git - Tools for git repository manipulation
    git =
      (officialServer {
        name = "git";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Memory - Knowledge graph-based persistent context
    memory =
      (officialServer {
        name = "memory";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Sequential Thinking - Problem-solving through thought sequences
    sequentialthinking =
      (officialServer {
        name = "sequentialthinking";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Time - Timezone conversion utilities
    time =
      (officialServer {
        name = "time";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # ================================================================
    # Infrastructure & DevOps (Native nixpkgs packages)
    # ================================================================

    # Terraform - Available in nixpkgs as native package
    terraform = mkServer {
      enabled = true;
      command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
    };

    # GitHub - Available in nixpkgs as native package
    github = mkServer {
      enabled = true;
      command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = "";
      };
    };

    # Docker - Container management via docker CLI
    docker = mkServer {
      enabled = true;
      command = "${pkgs.docker}/bin/docker";
    };

    # ================================================================
    # Search (from official MCP servers repo)
    # ================================================================

    # Exa - AI-focused semantic search
    exa =
      (officialServer {
        name = "exa";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
        env = {
          EXA_API_KEY = "";
        };
      };

    # Firecrawl - Web scraping for LLMs
    firecrawl =
      (officialServer {
        name = "firecrawl";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
        env = {
          FIRECRAWL_API_KEY = "";
        };
      };

    # ================================================================
    # Cloud Services (from official MCP servers repo)
    # ================================================================

    # Cloudflare - Workers, KV, R2, D1 management
    cloudflare =
      (officialServer {
        name = "cloudflare";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
        env = {
          CLOUDFLARE_API_TOKEN = "";
          CLOUDFLARE_ACCOUNT_ID = "";
        };
      };

    # AWS - Multi-service AWS integration
    aws =
      (officialServer {
        name = "aws-kb-retrieval-server";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
        env = {
          AWS_ACCESS_KEY_ID = "";
          AWS_SECRET_ACCESS_KEY = "";
          AWS_REGION = "us-east-1";
        };
      };

    # ================================================================
    # Database (disabled by default - require setup)
    # ================================================================

    # PostgreSQL - Database queries with natural language
    postgresql =
      (officialServer {
        name = "postgres";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          DATABASE_URL = "";
        };
      };

    # SQLite - Local database queries
    sqlite =
      (officialServer {
        name = "sqlite";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          SQLITE_DB_PATH = "";
        };
      };

    # ================================================================
    # Additional Official Servers (disabled - specialized use cases)
    # ================================================================

    # Brave Search - Web search capabilities
    brave-search =
      (officialServer {
        name = "brave-search";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          BRAVE_API_KEY = "";
        };
      };

    # Google Drive - Google Drive file access
    gdrive =
      (officialServer {
        name = "gdrive";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          GDRIVE_CREDENTIALS = "";
        };
      };

    # Google Maps - Location and mapping services
    google-maps =
      (officialServer {
        name = "google-maps";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          GOOGLE_MAPS_API_KEY = "";
        };
      };

    # Puppeteer - Browser automation (alternative to Playwright)
    puppeteer =
      (officialServer {
        name = "puppeteer";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
      };

    # Slack - Team communication integration
    slack =
      (officialServer {
        name = "slack";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          SLACK_BOT_TOKEN = "";
          SLACK_TEAM_ID = "";
        };
      };

    # Sentry - Error tracking and monitoring
    sentry =
      (officialServer {
        name = "sentry";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          SENTRY_AUTH_TOKEN = "";
        };
      };
  };
}

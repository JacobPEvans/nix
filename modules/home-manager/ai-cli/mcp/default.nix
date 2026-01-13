# MCP Servers Configuration - Nix-Native
#
# Strategy: Avoid runtime npm/npx/bunx entirely
# All MCP servers are either:
# 1. Native nixpkgs packages (terraform-mcp-server, github-mcp-server, etc.)
# 2. Fetched and cached from GitHub (Anthropic & community MCP servers)
#
# No runtime dependency installation - everything is deterministic and cached.

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

  # Helper to fetch MCP server from Anthropic official repo
  anthropicServer =
    {
      name,
      hash,
    }:
    mkServer {
      command = "${pkgs.nodejs}/bin/node";
      args = [
        "${
          pkgs.fetchFromGitHub {
            owner = "anthropics";
            repo = "mcp-servers";
            rev = "main";
            sparseCheckout = [ "src/${name}" ];
            sha256 = hash;
          }
        }/src/${name}/dist/index.js"
      ];
    };

  # Helper to fetch MCP server from modelcontextprotocol community repo
  communityServer =
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
    # Tier 1: Essential Utilities
    # ================================================================

    # Filesystem - Secure file system access
    filesystem =
      (anthropicServer {
        name = "filesystem";
        hash = lib.fakeHash; # TODO: Replace with actual hash from: nix hash path /path/to/fetched/repo
      })
      // {
        enable = true;
      };

    # Sequential Thinking - Multi-step reasoning
    sequential-thinking =
      (anthropicServer {
        name = "sequential-thinking";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # Memory - Persistent context across sessions
    memory =
      (anthropicServer {
        name = "memory";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # ================================================================
    # Browser Automation
    # ================================================================

    # Playwright - Browser automation and testing
    playwright =
      (anthropicServer {
        name = "playwright";
        hash = lib.fakeHash;
      })
      // {
        enable = true;
      };

    # ================================================================
    # Infrastructure & DevOps (Native nixpkgs)
    # ================================================================

    # Terraform - Available in nixpkgs as native package
    terraform = mkServer {
      enabled = true;
      command = "${pkgs.terraform-mcp-server}/bin/terraform-mcp-server";
    };

    # GitHub - Available in nixpkgs as native package
    github = mkServer {
      enabled = false;
      command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
      env = {
        GITHUB_PERSONAL_ACCESS_TOKEN = "";
      };
    };

    # Docker - Available in nixpkgs
    docker = mkServer {
      enabled = false;
      command = "${pkgs.docker}/bin/docker";
    };

    # ================================================================
    # Database
    # ================================================================

    # PostgreSQL - Database queries with natural language
    postgresql =
      (anthropicServer {
        name = "postgres";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          DATABASE_URL = "";
        };
      };

    # Supabase - Database + auth + edge functions
    supabase =
      (anthropicServer {
        name = "supabase";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          SUPABASE_URL = "";
          SUPABASE_KEY = "";
        };
      };

    # ================================================================
    # Search (Community servers)
    # ================================================================

    # Brave Search - Web search capabilities
    brave-search =
      (communityServer {
        name = "brave-search";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          BRAVE_API_KEY = "";
        };
      };

    # Exa - AI-focused semantic search
    exa =
      (communityServer {
        name = "exa";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          EXA_API_KEY = "";
        };
      };

    # Firecrawl - Web scraping for LLMs
    firecrawl =
      (communityServer {
        name = "firecrawl";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          FIRECRAWL_API_KEY = "";
        };
      };

    # ================================================================
    # Cloud Services
    # ================================================================

    # Cloudflare - Workers, KV, R2, D1 management
    cloudflare =
      (anthropicServer {
        name = "cloudflare";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          CLOUDFLARE_API_TOKEN = "";
          CLOUDFLARE_ACCOUNT_ID = "";
        };
      };

    # AWS - Multi-service AWS integration
    aws =
      (anthropicServer {
        name = "aws";
        hash = lib.fakeHash;
      })
      // {
        enable = false;
        env = {
          AWS_ACCESS_KEY_ID = "";
          AWS_SECRET_ACCESS_KEY = "";
          AWS_REGION = "us-east-1";
        };
      };
  };
}

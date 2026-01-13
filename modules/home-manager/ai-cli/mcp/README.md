# MCP Servers - Nix-Native Configuration

All MCP servers are built/fetched and cached at Nix evaluation time. No runtime npm,
npx, or bunx - everything is deterministic and reproducible.

## Architecture

- **Native nixpkgs packages**: terraform-mcp-server, github-mcp-server, docker, etc.
  - Referenced directly with `pkgs.package-name`
  - Always up-to-date with nixpkgs version

- **Fetched from GitHub**: Anthropic official and community MCP servers
  - `anthropics/mcp-servers` - Official Anthropic MCP servers
  - `modelcontextprotocol/servers` - Community-maintained servers
  - Fetched once and cached in `/nix/store`

## Enabling Servers

Edit `modules/home-manager/ai-cli/mcp/default.nix` and set `enable = true`
for the servers you want to use.

```nix
# Example: Enable GitHub MCP Server
github = mkServer {
  enabled = true;  # Set to true
  command = "${pkgs.github-mcp-server}/bin/github-mcp-server";
  env = {
    GITHUB_PERSONAL_ACCESS_TOKEN = "";
  };
};
```

## Updating Hashes

When you add a new server or update the GitHub revisions, you'll need to generate
correct hashes for the `fetchFromGitHub` calls.

### Method 1: Let Nix calculate the hash

1. Build your configuration:

   ```bash
   darwin-rebuild switch --flake . 2>&1 | grep "got: sha256"
   ```

2. Copy the hash from the error message
3. Replace `lib.fakeHash` with the actual hash

### Method 2: Pre-calculate the hash

```bash
# For Anthropic servers
nix-hash --flat --sri --type sha256 \
  $(nix flake prefetch --json github:anthropics/mcp-servers main | jq -r '.storePath')

# For community servers
nix-hash --flat --sri --type sha256 \
  $(nix flake prefetch --json github:modelcontextprotocol/servers main | jq -r '.storePath')
```

## Secrets Management

MCP servers requiring API keys have empty `env` values by default:

```nix
brave-search = (communityServer {
  name = "brave-search";
  hash = lib.fakeHash;
})
// {
  enable = false;
  env = {
    BRAVE_API_KEY = "";  # Set this via environment or keychain
  };
};
```

To use a server requiring secrets, set the env var before running Claude Code:

```bash
export BRAVE_API_KEY="your-api-key"
# OR set it in ~/.claude/settings.json
```

## Adding New Servers

1. Determine the server source:
   - Check if it's in nixpkgs: `nix search nixpkgs mcp-server`
   - Otherwise, find it in GitHub (Anthropic or community repos)

2. For nixpkgs packages:

   ```nix
   my-server = mkServer {
     enabled = false;
     command = "${pkgs.my-mcp-server}/bin/my-mcp-server";
   };
   ```

3. For GitHub servers:

   ```nix
   my-server = (anthropicServer {
     name = "my-server";
     hash = lib.fakeHash;  # Generate actual hash
   }) // { enable = false; };
   ```

4. Run `darwin-rebuild switch --flake .` to calculate the hash

## Performance

- **First build**: Fetches repos and caches in `/nix/store`
- **Subsequent builds**: Cache hit - instant
- **Zero runtime overhead**: All servers ready to use immediately

## Troubleshooting

### "hash mismatch" error

The cached hash doesn't match. Generate new hash (Method 1 above).

### "not found" when running server

Node.js servers: Check `${pkgs.nodejs}/bin/node` path
Native packages: Verify package exists: `nix search nixpkgs package-name`

### Server not loading in Claude Code

1. Check `enable = true` in mcp/default.nix
2. Run `darwin-rebuild switch --flake .`
3. Restart Claude Code
4. Verify in Claude Code: check `/mcp` command

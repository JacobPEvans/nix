# CI Workflow Rules

## Nix Caching in GitHub Actions

### Current Approach

We use `nix-community/cache-nix-action@v7` for Nix store caching. It is Nix-aware,
free, and uses the `actions/cache` backend. PRs are configured as restore-only (`save: false`);
cache saves happen only on main pushes. `gc-max-store-size` keeps the cache from growing unbounded.

`cache-nix-action` does not require `id-token: write` — it uses `github.token` only.

`auto-optimise-store = false` is set for the macOS Nix build workflow via `extra-conf` in
`.github/workflows/_nix-build.yml` because hardlinks break tar-based caching
(see nix-community/cache-nix-action#170).

### What We Tried and Why We Moved On

- **`DeterminateSystems/magic-nix-cache-action`**: Caused a 2.5x wall-time regression
  (8-10min baseline → 24-26min) because it uploads the full Nix store on every run with no
  restore-only mode. It also relies on undocumented GitHub APIs that broke in Feb 2025.
  Abandoned after confirming the regression across multiple runs.

- **Raw `actions/cache` on `/nix/store`**: Fails with tar extraction errors due to the
  special permissions and hardlinks in the Nix store. Not viable without significant workarounds.

- **`DeterminateSystems/flakehub-cache-action`**: Paid service. Not used.

### What Is Unknown

- Long-term stability of `cache-nix-action@v7` — it is community-maintained; check for
  upstream issues before upgrading major versions.
- Cache hit rates over time as `flake.lock` changes. First runs after a lockfile update
  will fall back to prefix-matching, which may be slower than a full cache hit.
- Whether the baseline (8-10min) holds as the configuration grows.

## Performance Expectations

Timing steps are included before and after build/check steps to measure CI wall time.
Cache changes should be validated against the baseline (8-10min for Nix Build on macOS-latest).
First runs after a `flake.lock` change will be cold-cache and may take longer — that is normal,
not a regression.

PR runs are restore-only. Cache saving is deferred to main to avoid wasting CI minutes on
branches that may never merge.

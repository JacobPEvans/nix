# GitHub token context switching — principle of least privilege
# Tokens are tiered PATs stored in macOS Keychain.
# Restricted: automation.keychain-db (unrestricted, AI can access freely)
# Private/Admin: elevate-access.keychain-db (password-protected, requires user unlock)
# Usage: gh-restricted | gh-private | gh-admin | gh-token-status

_gh_switch_token() {
  local svc="$1" db="$2" mode="$3" desc="$4"
  local token
  token=$(_get_keychain_secret "$svc" "$_KC_AI_ACCOUNT" "$db")
  if [[ -z "$token" ]]; then
    echo "ERROR: No keychain entry for service '$svc' in '$db'"
    echo "Add it:  security add-generic-password -U -s '$svc' -a '$_KC_AI_ACCOUNT' -w '<token>' '$db'"
    return 1
  fi
  export GITHUB_TOKEN="$token"
  export GH_ENV_MODE="$mode"
  echo "GitHub context: $mode ($desc)"
}

gh-restricted() {
  _gh_switch_token "$_GH_SVC_RESTRICTED" "$_GH_DB_RESTRICTED" "RESTRICTED" "public repos"
}

gh-private() {
  _gh_switch_token "$_GH_SVC_PRIVATE" "$_GH_DB_PRIVATE" "PRIVATE" "+ private repos"
}

gh-admin() {
  _gh_switch_token "$_GH_SVC_ADMIN" "$_GH_DB_ADMIN" "ADMIN" "full access"
}

gh-token-status() {
  echo "GH_ENV_MODE=${GH_ENV_MODE:-unset}"
  if [[ -n "$GITHUB_TOKEN" ]]; then
    echo "GITHUB_TOKEN=set (${#GITHUB_TOKEN} chars)"
  else
    echo "GITHUB_TOKEN=unset"
  fi
}

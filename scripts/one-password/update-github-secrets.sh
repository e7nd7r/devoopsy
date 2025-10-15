#!/bin/bash

# ensure_gh_auth
# Ensures the GitHub CLI (gh) is authenticated to the given host (default: github.com).
#
# Arguments:
#   $1 (optional) - host to authenticate to (default: github.com)
#
# Behavior:
#   - If the 'gh' CLI is installed and already authenticated to the host, returns 0.
#   - In non-interactive environments (CI), if GH_TOKEN or GITHUB_TOKEN is present, it
#     logs in non-interactively using the token.
#   - Otherwise it initiates an interactive web login flow requesting the scopes
#     required by this script (repo, read:org, workflow).
#
# Returns:
#   Exits with 0 when authentication is verified, 1 on failure. Helpful status messages
#   are printed to stderr to aid debugging.
#
# Use cases:
#   - Scripts that need to ensure 'gh' is authenticated before calling other gh commands.
#   - CI pipelines where GH_TOKEN or GITHUB_TOKEN can be provided to authenticate non-interactively.
#   - Local developer runs that can fall back to an interactive web login when needed.
ensure_gh_auth() {
    local host="${1:-github.com}"

    if command -v gh >/dev/null 2>&1; then
        if gh auth status -h "$host" >/dev/null 2>&1; then
            echo "✅ Already authenticated to $host" >&2

            return 0
        fi

        # Non-interactive (CI): use GH_TOKEN or GITHUB_TOKEN if present
        if [[ -n "${GH_TOKEN:-}" || -n "${GITHUB_TOKEN:-}" ]]; then
            echo "🔐 Logging in to $host with token from env..." >&2

            printf '%s' "${GH_TOKEN:-$GITHUB_TOKEN}" | gh auth login -h "$host" --with-token
        else
            # Interactive login (web flow). Add scopes you need.
            echo "🌐 Starting interactive login to $host..." >&2

            gh auth login -h "$host" -p https -s "repo,read:org,workflow" -w
        fi

        # Verify
        if gh auth status --hostname="$host" >/dev/null 2>&1; then
            echo "✅ Authentication successful." >&2
            return 0
        else
            echo "❌ Authentication failed." >&2
            return 1
        fi

    else
        echo "ℹ️ 'gh' not found; checking SSH auth to $host..." >&2

        cat >&2 <<'EOF'
❌ Not authenticated:
- Install GitHub CLI: https://cli.github.com/ (recommended), or
- Set up SSH keys: https://docs.github.com/authentication/connecting-to-github-with-ssh
EOF

        return 1
    fi
}

# set_gh_secret
# Sets a GitHub Actions/Repository secret using the GitHub CLI (gh).
#
# Arguments:
#   $1 - repo: The repository in the format owner/repo (required).
#   $2 - key: The secret name to set (required).
#   $3 - value: The secret value to store (required).
#   $4 - env: (optional) If provided, the secret is set for that environment
#        within the repository using the -e/--env flag. When omitted, the
#        secret is set at the repository level.
#
# Behavior:
#   - Ensures the 'gh' CLI is authenticated by calling ensure_gh_auth(). If
#     authentication fails the script exits with status 1.
#   - If an environment name is provided the secret is created for that
#     environment; otherwise it is created at the repository scope.
#   - Returns 0 on success. Prints informational messages to stderr for
#     visibility.
#
# Use cases:
#   - CI/CD pipelines that need to programmatically update repository or
#     environment secrets before running workflows.
#   - Local developer scripts to bootstrap or rotate secrets across multiple
#     repos or environments.
#   - Automation tooling that syncs secrets from a centralized vault into
#     GitHub repos or environments.
set_gh_secret() {
    local repo key value env

    repo="$1:?Repository required."
    key="$2?Key required."
    value="$3:?Value Required"
    env="$4"

    if ! ensure_gh_auth; then
        echo "❌ \e[31mCould not authenticate to GitHub. Exiting...\e[0m" >&2
        exit 1
    fi
    if [[ -n "$env" ]]; then
        echo "[INFO] Setting secret for ${key} in ${env}." >&2
        gh secret set "$key" -R "$repo" -e "$env" --body "${value}"
    else
        echo "[INFO] Setting secret with ${key} globally." >&2
        gh secret set "$key" -R "$repo" --body "${value}"
    fi

    echo "[INFO] $key set successfully." >&2

    return 0
}

# get_op_secret
# Reads a secret value from 1Password using the op CLI.
#
# Arguments:
#   $1 - vault: The 1Password vault name or UUID that contains the item (required).
#   $2 - item_name: The name (or id) of the 1Password item to read (required).
#   $3 - section: The section or field group inside the 1Password item (optional,
#        depends on how the item is organized).
#   $4 - key: The specific field name within the section to read (optional).
#
# Behavior:
#   - Invokes `op read` to retrieve the secret value. Ensure the 1Password CLI
#     (op) is installed and authenticated before calling this function.
#   - Returns the secret value on stdout so it can be captured by callers.
#
# Use cases:
#   - CI jobs that pull secrets from a centralized 1Password vault before
#     setting them as GitHub repository or environment secrets.
#   - Local automation scripts that read developer credentials or tokens from
#     1Password for short-lived use in scripts (avoid printing secrets to logs).
#   - Secret rotation tooling which reads values from 1Password and propagates
#     them to downstream systems like GitHub Actions, cloud providers, or
#     deployment pipelines.
get_op_secret() {
    local vault item_name section key

    vault="$1: ?1Password vault required."
    item_name="$2:?Item name required."
    section="$3:? "
    key="$4"

    echo "[INFO] Getting 1password secret" >&2
    op read -n "op://${vault}/$itemName/$section/$key"
}

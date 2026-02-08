#!/usr/bin/env bash
# GitHub helper script that uses the gh CLI for common operations.
# Usage:
#   github-api.sh repo owner/repo              - Get repository info
#   github-api.sh issues owner/repo [query]    - Search issues/PRs
#   github-api.sh search "code query" [lang]   - Search code across GitHub
#   github-api.sh readme owner/repo            - Get README content
#   github-api.sh tree owner/repo [path]       - List repository contents

set -euo pipefail

require_gh() {
    if command -v gh >/dev/null 2>&1; then
        return
    fi

    cat <<EOF
Error: GitHub CLI (gh) is required but not installed.

Install gh:
  macOS:   brew install gh
  Ubuntu:  sudo apt update && sudo apt install gh
  Fedora:  sudo dnf install gh
  Arch:    sudo pacman -S github-cli

Then authenticate:
  gh auth login
EOF
    exit 1
}

usage() {
    cat <<EOF
GitHub Helper (gh CLI)

Commands:
  repo owner/repo              Get repository metadata (stars, forks, description)
  issues owner/repo [query]    Search issues and PRs (optional query filter)
  search "query" [qualifier]   Search code across GitHub (e.g., "useEffect" lang:typescript)
  readme owner/repo            Fetch and decode README content
  tree owner/repo [path]       List directory contents (default: root)

Requirements:
  gh                           GitHub CLI (https://cli.github.com/)
  jq                           JSON processing for local filtering/formatting

Examples:
  github-api.sh repo facebook/react
  github-api.sh issues vercel/next.js "app router"
  github-api.sh search "async function" lang:typescript
  github-api.sh readme anthropics/anthropic-sdk-python
  github-api.sh tree microsoft/vscode src/vs/editor
EOF
    exit 1
}

cmd_repo() {
    local repo="$1"
    gh repo view "$repo" --json nameWithOwner,description,stargazerCount,forkCount,primaryLanguage,repositoryTopics,defaultBranchRef,updatedAt,url | jq '{
        name: .nameWithOwner,
        description: .description,
        stars: .stargazerCount,
        forks: .forkCount,
        language: (.primaryLanguage.name // null),
        topics: [.repositoryTopics[].topic.name],
        default_branch: (.defaultBranchRef.name // null),
        updated_at: .updatedAt,
        html_url: .url
    }'
}

cmd_issues() {
    local repo="$1"
    local query="${2:-}"
    local search_query="repo:$repo is:issue"
    if [[ -n "$query" ]]; then
        search_query="$search_query $query"
    fi
    gh search issues "$search_query" --limit 10 --json number,title,state,labels,createdAt,url,body | jq 'map({
        number: .number,
        title: .title,
        state: .state,
        labels: [.labels[].name],
        created_at: .createdAt,
        html_url: .url,
        body_preview: (.body // "" | .[0:200])
    })'
}

cmd_search() {
    local query="$1"
    local qualifier="${2:-}"
    local search_query="$query"
    if [[ -n "$qualifier" ]]; then
        search_query="$query $qualifier"
    fi
    gh search code "$search_query" --limit 10 --json repository,path,url | jq 'map({
        repo: .repository.nameWithOwner,
        path: .path,
        html_url: .url
    })'
}

cmd_readme() {
    local repo="$1"
    gh api "repos/$repo/readme" --jq '.content' | base64 -d 2>/dev/null || echo "Could not decode README"
}

cmd_tree() {
    local repo="$1"
    local path="${2:-.}"
    local endpoint="repos/$repo/contents"
    if [[ "$path" != "." ]]; then
        endpoint="$endpoint/$path"
    fi
    gh api "$endpoint" | jq 'if type == "array" then map({name: .name, type: .type, size: .size, path: .path}) else {name: .name, type: .type, size: .size, content: (.content // null)} end'
}

# Main dispatch
[[ $# -lt 1 ]] && usage
[[ "$1" == "-h" || "$1" == "--help" ]] && usage
require_gh

case "$1" in
    repo)
        [[ $# -lt 2 ]] && usage
        cmd_repo "$2"
        ;;
    issues)
        [[ $# -lt 2 ]] && usage
        cmd_issues "$2" "${3:-}"
        ;;
    search)
        [[ $# -lt 2 ]] && usage
        cmd_search "$2" "${3:-}"
        ;;
    readme)
        [[ $# -lt 2 ]] && usage
        cmd_readme "$2"
        ;;
    tree)
        [[ $# -lt 2 ]] && usage
        cmd_tree "$2" "${3:-}"
        ;;
    *)
        usage
        ;;
esac

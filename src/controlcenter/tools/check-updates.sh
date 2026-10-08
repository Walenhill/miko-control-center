#!/usr/bin/env bash
# Read-only queries. Every source carries its own result; empty output is not success.
set -u
umask 077
work="$(mktemp -d)" || exit 1
trap 'rm -rf -- "$work"' EXIT

repository_status=unavailable
aur_status=unavailable
repository_tool=none
aur_tool=none
: >"$work/repository"
: >"$work/aur"
: >"$work/repository-error"
: >"$work/aur-error"

if command -v checkupdates >/dev/null 2>&1; then
    repository_tool=checkupdates
    timeout 45s checkupdates >"$work/repository" 2>"$work/repository-error"
    result=$?
    if [[ $result == 0 || $result == 2 ]]; then
        repository_status=ok
    else
        repository_status=error
    fi
elif command -v pacman >/dev/null 2>&1; then
    repository_tool=pacman
    # This query reads the existing sync database; it cannot confirm freshness.
    if pacman -Qu >"$work/repository" 2>"$work/repository-error"; then
        repository_status=cached
    else
        repository_status=error
    fi
fi

if command -v paru >/dev/null 2>&1; then
    aur_tool=paru
elif command -v yay >/dev/null 2>&1; then
    aur_tool=yay
fi
if [[ $aur_tool != none ]]; then
    if timeout 45s "$aur_tool" -Qua >"$work/aur" 2>"$work/aur-error"; then
        aur_status=ok
    else
        aur_status=error
    fi
fi

jq -n --arg repositoryStatus "$repository_status" --arg aurStatus "$aur_status" \
    --arg repositoryTool "$repository_tool" --arg aurTool "$aur_tool" \
    --rawfile repository "$work/repository" --rawfile aur "$work/aur" \
    --rawfile repositoryError "$work/repository-error" --rawfile aurError "$work/aur-error" \
    '{repositoryStatus: $repositoryStatus, aurStatus: $aurStatus,
      repositoryTool: $repositoryTool, aurTool: $aurTool,
      repository: $repository, aur: $aur,
      repositoryError: $repositoryError, aurError: $aurError}'

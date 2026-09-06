#!/bin/bash

#
# Release Management Script
#
# Drives the release flow described in docs/release-process.md:
#   develop ──cut──▶ release/X.Y.Z ──tag──▶ vX.Y.Z ──build──▶ beta (TestFlight)
#                        ▲   │
#            pick (fixes)┘   └──finish──▶ PR back into develop
#
# Every command validates its preconditions and fails loudly. Nothing here
# pushes to origin unless --push is given explicitly.
#
# USAGE:
#   ./Tools/release.sh status
#       Current version, release/hotfix branches, tags, recent beta builds.
#
#   ./Tools/release.sh cut X.Y.Z [--from <ref>] [--push]
#       Create release/X.Y.Z from origin/develop (or <ref>), bump
#       MARKETING_VERSION to X.Y.Z and commit. --push pushes the branch.
#
#   ./Tools/release.sh hotfix X.Y.Z --from vA.B.C [--push]
#       Create hotfix/X.Y.Z from an existing release tag, bump version, commit.
#
#   ./Tools/release.sh pick <sha|PR#> [...] [--push]
#       Cherry-pick commits (or the merge commits of PRs) into the current
#       release/hotfix branch. PR numbers are resolved via gh.
#
#   ./Tools/release.sh tag [--push] [--notes]
#       Create annotated tag vX.Y.Z on the head of the current release/hotfix
#       branch. Version in the project must equal X.Y.Z from the branch name.
#       --push pushes the tag; --notes also creates a GitHub pre-release with
#       auto-generated notes (requires --push).
#
#   ./Tools/release.sh build [X.Y.Z] [--watch]
#       Trigger "Generate IPA" (flavor beta) on tag vX.Y.Z. Defaults to the
#       version of the current release/hotfix branch. --watch follows the run.
#
#   ./Tools/release.sh finish
#       Open a PR from the current release/hotfix branch back into develop so
#       the version bump and cherry-picked fixes land there too.
#
# REQUIREMENTS: git, gh (authenticated), python3.
#

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PROJECT_FILE="$ROOT/animeal.xcodeproj/project.pbxproj"
WORKFLOW="GenerateIPA.yml"
BASE_BRANCH="develop"

# ---------------------------------------------------------------- helpers ---

die()  { echo "❌ $*" >&2; exit 1; }
info() { echo "ℹ️  $*"; }
ok()   { echo "✅ $*"; }
warn() { echo "⚠️  $*"; }

usage() {
    sed -n '3,45p' "$0" | sed 's/^# \{0,1\}//'
}

require_clean_tree() {
    if [ -n "$(git -C "$ROOT" status --porcelain)" ]; then
        die "Working tree is not clean — commit or move your changes aside first"
    fi
}

require_gh() {
    command -v gh >/dev/null 2>&1 || die "gh CLI is required for this command"
    gh auth status >/dev/null 2>&1 || die "gh is not authenticated — run 'gh auth login'"
}

is_semver() { [[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; }

# Prints the single X.Y.Z MARKETING_VERSION of the main target.
current_version() {
    local versions
    versions=$(grep -oE 'MARKETING_VERSION = [0-9]+\.[0-9]+\.[0-9]+;' "$PROJECT_FILE" | sort -u)
    [ "$(echo "$versions" | grep -c .)" -eq 1 ] \
        || die "Main-target MARKETING_VERSION values diverged — fix manually first:\n$versions"
    echo "$versions" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+'
}

# version_gt A B  → true when A > B (semver).
version_gt() {
    [ "$1" != "$2" ] && [ "$(printf '%s\n%s\n' "$1" "$2" | sort -V | tail -1)" = "$1" ]
}

current_branch() { git -C "$ROOT" branch --show-current; }

# Prints X.Y.Z from release/X.Y.Z or hotfix/X.Y.Z, dies otherwise.
branch_version() {
    local branch
    branch=$(current_branch)
    [[ "$branch" =~ ^(release|hotfix)/([0-9]+\.[0-9]+\.[0-9]+)$ ]] \
        || die "Current branch '$branch' is not release/X.Y.Z or hotfix/X.Y.Z"
    echo "${BASH_REMATCH[2]}"
}

branch_exists_anywhere() {
    git -C "$ROOT" show-ref --verify --quiet "refs/heads/$1" && return 0
    git -C "$ROOT" ls-remote --exit-code --heads origin "$1" >/dev/null 2>&1 && return 0
    return 1
}

tag_exists_local()  { git -C "$ROOT" show-ref --verify --quiet "refs/tags/$1"; }
tag_exists_remote() { git -C "$ROOT" ls-remote --exit-code --tags origin "refs/tags/$1" >/dev/null 2>&1; }

# Creates <kind>/X.Y.Z from <start-ref>, bumps version, commits.
create_versioned_branch() {
    local kind="$1" version="$2" start_ref="$3" push="$4"
    local branch="$kind/$version"
    local current

    require_clean_tree
    current=$(current_version)

    version_gt "$version" "$current" \
        || die "Target version $version must be greater than current $current"
    branch_exists_anywhere "$branch" && die "Branch $branch already exists (locally or on origin)"
    tag_exists_local "v$version" || tag_exists_remote "v$version" \
        && die "Tag v$version already exists — pick a new version"

    info "Fetching origin…"
    git -C "$ROOT" fetch origin --tags --quiet
    git -C "$ROOT" rev-parse --verify --quiet "$start_ref^{commit}" >/dev/null \
        || die "Start ref '$start_ref' not found"

    info "Creating $branch from $start_ref ($(git -C "$ROOT" rev-parse --short "$start_ref"))"
    git -C "$ROOT" checkout -b "$branch" "$start_ref" --quiet

    bash "$ROOT/Tools/bump_version.sh" "$version" --yes
    git -C "$ROOT" add animeal.xcodeproj/project.pbxproj
    git -C "$ROOT" commit --quiet -m "Bump version to $version"
    ok "$branch created at $(git -C "$ROOT" rev-parse --short HEAD), version $current -> $version"

    if [ "$push" = "1" ]; then
        git -C "$ROOT" push -u origin "$branch"
        ok "Pushed $branch to origin"
    else
        info "Not pushed. Push with: git push -u origin $branch"
    fi
}

# --------------------------------------------------------------- commands ---

cmd_status() {
    local version branch
    version=$(current_version)
    branch=$(current_branch)

    git -C "$ROOT" fetch origin --tags --quiet 2>/dev/null || warn "Could not fetch origin (offline?)"

    echo "Project version : $version"
    echo "Current branch  : $branch"
    echo
    echo "Release/hotfix branches on origin:"
    git -C "$ROOT" branch -r --list 'origin/release/*' 'origin/hotfix/*' | sed 's/^/  /' | grep . || echo "  (none)"
    echo
    echo "Latest tags:"
    git -C "$ROOT" tag -l 'v*' --sort=-v:refname | head -5 | sed 's/^/  /' | grep . || echo "  (none)"
    echo

    if tag_exists_local "v$version" || tag_exists_remote "v$version"; then
        echo "Tag v$version      : exists"
    else
        echo "Tag v$version      : not yet created"
    fi

    if command -v gh >/dev/null 2>&1 && gh auth status >/dev/null 2>&1; then
        echo
        echo "Recent 'Generate IPA' runs:"
        gh run list --workflow "$WORKFLOW" --limit 5 \
            --json status,conclusion,headBranch,event,createdAt,url \
            --template '{{range .}}  {{.status}}/{{or .conclusion "-"}}  {{.headBranch}}  ({{.event}})  {{timeago .createdAt}}  {{.url}}{{"\n"}}{{end}}' \
            2>/dev/null || echo "  (unavailable)"
    fi
}

cmd_cut() {
    local version="" start_ref="origin/$BASE_BRANCH" push=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --from) start_ref="$2"; shift 2 ;;
            --push) push=1; shift ;;
            *) [ -z "$version" ] && version="$1" || die "Unexpected argument: $1"; shift ;;
        esac
    done
    [ -n "$version" ] || die "Usage: release.sh cut X.Y.Z [--from <ref>] [--push]"
    is_semver "$version" || die "Invalid version '$version' (expected X.Y.Z)"
    create_versioned_branch release "$version" "$start_ref" "$push"
}

cmd_hotfix() {
    local version="" start_ref="" push=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --from) start_ref="$2"; shift 2 ;;
            --push) push=1; shift ;;
            *) [ -z "$version" ] && version="$1" || die "Unexpected argument: $1"; shift ;;
        esac
    done
    [ -n "$version" ] && [ -n "$start_ref" ] \
        || die "Usage: release.sh hotfix X.Y.Z --from vA.B.C [--push]"
    is_semver "$version" || die "Invalid version '$version' (expected X.Y.Z)"
    [[ "$start_ref" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]] \
        || die "Hotfixes start from a release tag (vA.B.C), got '$start_ref'"
    git -C "$ROOT" fetch origin --tags --quiet
    tag_exists_local "$start_ref" || die "Tag $start_ref not found"
    create_versioned_branch hotfix "$version" "$start_ref" "$push"
}

cmd_pick() {
    local push=0 refs=() ref sha
    while [ $# -gt 0 ]; do
        case "$1" in
            --push) push=1; shift ;;
            *) refs+=("$1"); shift ;;
        esac
    done
    [ ${#refs[@]} -gt 0 ] || die "Usage: release.sh pick <sha|PR#> [...] [--push]"

    local version branch
    version=$(branch_version)
    branch=$(current_branch)
    require_clean_tree
    git -C "$ROOT" fetch origin --quiet

    for ref in "${refs[@]}"; do
        if [[ "$ref" =~ ^#?[0-9]+$ ]]; then
            require_gh
            sha=$(gh pr view "${ref#\#}" --json mergeCommit,state -q '.mergeCommit.oid // empty')
            [ -n "$sha" ] || die "PR ${ref} has no merge commit (not merged yet?)"
            info "PR ${ref} -> $(git -C "$ROOT" rev-parse --short "$sha")"
        else
            sha=$(git -C "$ROOT" rev-parse --verify --quiet "$ref^{commit}") \
                || die "Commit '$ref' not found (fetch first?)"
        fi
        git -C "$ROOT" cherry-pick -x "$sha" \
            || die "Cherry-pick of $sha failed — resolve conflicts, 'git cherry-pick --continue', then re-run for the remaining refs"
        ok "Picked $(git -C "$ROOT" log -1 --format='%h %s' "$sha")"
    done

    if [ "$push" = "1" ]; then
        git -C "$ROOT" push origin "$branch"
        ok "Pushed $branch"
    else
        info "Not pushed. Push with: git push origin $branch"
    fi
    info "Release $version now at $(git -C "$ROOT" rev-parse --short HEAD)"
}

cmd_tag() {
    local push=0 notes=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --push)  push=1; shift ;;
            --notes) notes=1; shift ;;
            *) die "Unexpected argument: $1" ;;
        esac
    done
    [ "$notes" = "1" ] && [ "$push" = "0" ] && die "--notes requires --push"

    local version branch project_version tag
    version=$(branch_version)
    branch=$(current_branch)
    tag="v$version"
    require_clean_tree
    project_version=$(current_version)
    [ "$project_version" = "$version" ] \
        || die "Branch says $version but MARKETING_VERSION is $project_version — run Tools/bump_version.sh $version first"

    git -C "$ROOT" fetch origin --tags --quiet
    tag_exists_local "$tag"  && die "Tag $tag already exists locally"
    tag_exists_remote "$tag" && die "Tag $tag already exists on origin"

    local head remote_head
    head=$(git -C "$ROOT" rev-parse HEAD)
    remote_head=$(git -C "$ROOT" rev-parse --verify --quiet "origin/$branch" || true)
    [ "$head" = "$remote_head" ] \
        || die "HEAD of $branch is not on origin — push the branch first so CI can build the tag"

    git -C "$ROOT" tag -a "$tag" -m "Release $version"
    ok "Created $tag at $(git -C "$ROOT" rev-parse --short HEAD)"

    if [ "$push" = "1" ]; then
        git -C "$ROOT" push origin "$tag"
        ok "Pushed $tag"
        if [ "$notes" = "1" ]; then
            require_gh
            gh release create "$tag" --title "$version" --generate-notes --prerelease --verify-tag
            ok "GitHub pre-release $tag created with generated notes"
        fi
    else
        info "Not pushed. Push with: git push origin $tag"
    fi
}

cmd_build() {
    local version="" watch=0
    while [ $# -gt 0 ]; do
        case "$1" in
            --watch) watch=1; shift ;;
            *) [ -z "$version" ] && version="$1" || die "Unexpected argument: $1"; shift ;;
        esac
    done
    [ -n "$version" ] || version=$(branch_version)
    is_semver "$version" || die "Invalid version '$version' (expected X.Y.Z)"
    local tag="v$version"

    require_gh
    git -C "$ROOT" fetch origin --tags --quiet
    tag_exists_remote "$tag" || die "Tag $tag is not on origin — run 'release.sh tag --push' first"

    info "Triggering $WORKFLOW (flavor=beta) on $tag…"
    gh workflow run "$WORKFLOW" --ref "$tag" -f flavor=beta -f environment=default
    sleep 5
    local run_id
    run_id=$(gh run list --workflow "$WORKFLOW" --branch "$tag" --limit 1 --json databaseId -q '.[0].databaseId' || true)
    if [ -z "$run_id" ]; then
        warn "Run queued but not listed yet — check: gh run list --workflow $WORKFLOW"
        exit 0
    fi
    ok "Run $run_id started: $(gh run view "$run_id" --json url -q .url)"
    if [ "$watch" = "1" ]; then
        gh run watch "$run_id" --exit-status
    else
        info "Follow with: gh run watch $run_id"
    fi
}

cmd_finish() {
    local version branch
    version=$(branch_version)
    branch=$(current_branch)
    require_gh
    git -C "$ROOT" fetch origin --quiet
    git -C "$ROOT" rev-parse --verify --quiet "origin/$branch" >/dev/null \
        || die "$branch is not on origin — push it first"

    local existing
    existing=$(gh pr list --head "$branch" --base "$BASE_BRANCH" --json url -q '.[0].url' || true)
    if [ -n "$existing" ]; then
        ok "Merge-back PR already open: $existing"
        exit 0
    fi

    gh pr create --base "$BASE_BRANCH" --head "$branch" \
        --title "Merge back $branch into $BASE_BRANCH" \
        --body "$(cat <<EOF
Merge-back of \`$branch\` after shipping \`v$version\`.

Brings the version bump and any cherry-picked fixes into \`$BASE_BRANCH\`.
Resolve conflicts in favour of \`$BASE_BRANCH\` for everything except \`MARKETING_VERSION\`.
EOF
)"
    ok "Merge-back PR opened for $branch"
}

# ------------------------------------------------------------------- main ---

[ -f "$PROJECT_FILE" ] || die "Project file not found: $PROJECT_FILE"

COMMAND="${1:-}"
[ $# -gt 0 ] && shift

case "$COMMAND" in
    status) cmd_status "$@" ;;
    cut)    cmd_cut "$@" ;;
    hotfix) cmd_hotfix "$@" ;;
    pick)   cmd_pick "$@" ;;
    tag)    cmd_tag "$@" ;;
    build)  cmd_build "$@" ;;
    finish) cmd_finish "$@" ;;
    -h|--help|help|"") usage; [ -n "$COMMAND" ] || exit 1 ;;
    *) die "Unknown command '$COMMAND'. Run 'Tools/release.sh --help'" ;;
esac

# Animeal iOS — Build Flavors & Distribution


We ship two build flavors from the same codebase. They differ in backend,
tooling and how testers receive them.

| | **QA build** | **Beta build** |
|---|---|---|
| Purpose | day-to-day internal testing | release candidates for real beta testers |
| Backend | **dev** by default, switchable to test | **test** (fixed — this is our de-facto production) |
| How it's built | automatically on every merge to `develop` (GitHub Actions → Generate IPA) | manually, only from a release tag: `./Tools/release.sh build X.Y.Z` (or Actions → Generate IPA → Run workflow → flavor `beta`, ref = tag) |
| How to tell it apart | red diagonal "QA" ribbon on the icon, app name "Animeal QA" | regular icon and name |
| QA menu (More tab) | ✅ — shows active backend + host, **dev/test environment switcher**, feature toggles | ❌ not present |
| Distribution | TestFlight, internal group (appears automatically after upload) | TestFlight: verified internally first, then the external beta group is added to the build in App Store Connect |

**Important: the `test` backend is used by real beta testers in Georgia.**
Never create test data there. All experimental testing belongs on `dev` —
which is exactly what the QA build points to by default.

CI refuses to build the `beta` flavor from anything but a tag `vX.Y.Z` whose
version equals `MARKETING_VERSION` in the project. A beta build therefore can
never come from a random branch or from a mismatched version.

## Which build do I get?

| Action | Workflow trigger | Flavor | Configuration | QA menu | Backend |
|---|---|---|---|---|---|
| merge a PR into `develop` | push | `qa` (default) | QA | ✅ | dev |
| Actions → Run workflow, flavor `qa`, any ref | workflow_dispatch | `qa` | QA | ✅ | dev (or `test` via the environment input) |
| `./Tools/release.sh build X.Y.Z` (tag `vX.Y.Z`) | workflow_dispatch | `beta` | Release | ❌ | test |
| Actions → Run workflow, flavor `beta`, ref is a branch | workflow_dispatch | — | — | fails: beta needs a tag | — |

So a merge into `develop` always produces a build **with** the QA menu. A build
without it is the beta flavor, and the only way to get one is the release flow
below (cut → tag → build). This is deliberate: builds that reach real testers
must come from a tagged, version-matched commit on the `test` backend.

`QA_MENU` is a Swift compilation condition (`SWIFT_ACTIVE_COMPILATION_CONDITIONS`)
set in `animeal/Configurations/QA.xcconfig` for the QA configuration and in the
project's Debug configuration; Release never defines it, so everything under
`#if QA_MENU` is compiled out of beta builds.

## Switching backend in the QA build
More → QA Menu → Environment (dev / test). Switching signs you out, clears
local data and closes the app; the next launch runs against the selected
environment. The current backend (name + AppSync host) is always shown in
the QA menu.

## Versioning

| Number | Example | Who changes it | When |
|---|---|---|---|
| Marketing version (`MARKETING_VERSION`) | `1.0.3` | `Tools/release.sh cut` / `hotfix` | once per release — **not** per commit |
| Build number (`CURRENT_PROJECT_VERSION`) | `20260906.131` | CI (`Tools/update_build_number.sh`) | every build, automatically |
| Git tag | `v1.0.3` | `Tools/release.sh tag` | once, when the RC is approved for a beta build |

- Three numbers only (`X.Y.Z`): Apple rejects a fourth component in `CFBundleShortVersionString`.
- While work lands in `develop`, the version stays the same; only the build number grows. TestFlight shows both, e.g. `1.0.3 (20260906.131)`.
- Default bumps: a regular release is **+minor** (`1.0.3 → 1.1.0`), a hotfix is **+patch** (`1.1.0 → 1.1.1`). Major bumps are an explicit decision.
- A pushed tag is never moved or deleted. If a tagged build is bad, cut the next patch version.

## Release flow (RC → beta)

```
develop ──cut──▶ release/X.Y.Z ──tag──▶ vX.Y.Z ──build──▶ beta (TestFlight)
                     ▲   │
         pick (fixes)┘   └──finish──▶ PR back into develop
```

Every step is a `./Tools/release.sh` command (or the `/animeal-release` skill in
Claude Code, which wraps it with questions and confirmations). The script checks its
preconditions and refuses to continue otherwise; it never pushes without `--push`.

1. **Cut.** Pick the `develop` commit for the release candidate and create `release/X.Y.Z` from it. The marketing version is bumped on that branch in the same step; push the branch.
2. **Stabilise.** Fixes are merged to `develop` as usual and cherry-picked into the release branch; `develop` keeps moving. PRs into `release/*` run the same lint + unit-test pipeline as PRs into `develop`.
3. **Tag.** Tag the release branch head as `vX.Y.Z` and push the tag. Optionally create a GitHub pre-release with auto-generated notes.
4. **Build beta.** Trigger Generate IPA with flavor `beta` on the tag.
5. **Verify.** QA verifies the beta build from the internal TestFlight group — this is the RC check against the `test` backend.
6. **Ship.** Once approved, the beta group is added to that build in App Store Connect.
7. **Merge back.** Open a PR `release/X.Y.Z → develop` so the version bump and cherry-picked fixes land in `develop`. Without this step `develop` keeps the old `MARKETING_VERSION`.

## Command reference (`Tools/release.sh`)

| Command | What it does | Options | Refuses when |
|---|---|---|---|
| `status` | version, current branch, release/hotfix branches on origin, latest tags, recent Generate IPA runs | — | — |
| `cut X.Y.Z` | create `release/X.Y.Z` from `origin/develop`, bump version, commit | `--from <ref>` start from a specific commit/branch instead of `origin/develop`; `--push` push the branch right away | tree not clean; `X.Y.Z` ≤ current version; branch or tag `vX.Y.Z` already exists |
| `hotfix X.Y.Z --from vA.B.C` | create `hotfix/X.Y.Z` from a shipped tag, bump version, commit | `--push` | same as `cut`; `--from` is not an existing `v*` tag |
| `pick <sha\|PR#> [...]` | cherry-pick commits (or the merge commits of PRs, resolved via `gh`) into the current release/hotfix branch, `-x` trailer added | `--push` push the branch after picking | not on `release/*`/`hotfix/*`; tree not clean; PR not merged yet; cherry-pick conflict (stops, keeps the conflict for you to resolve) |
| `tag` | annotated tag `vX.Y.Z` on the head of the current release/hotfix branch, message `Release X.Y.Z` | `--push` push the tag; `--notes` also create a GitHub **pre-release** with generated notes (needs `--push`) | not on `release/*`/`hotfix/*`; `MARKETING_VERSION` ≠ branch version; tag exists locally or on origin; branch head not pushed |
| `build [X.Y.Z]` | trigger Generate IPA, flavor `beta`, ref `vX.Y.Z` (defaults to the current branch's version) | `--watch` follow the run until it finishes and exit with its status | tag `vX.Y.Z` not on origin |
| `finish` | open PR `release/X.Y.Z → develop` (or reuse the open one) | — | branch not on origin |

All commands need `git`; `pick` with PR numbers, `tag --notes`, `build` and `finish` need an authenticated `gh`.

## Scenarios

**A. Regular release (happy path)** — `develop` is at 1.0.2, everything for the release is merged.
```bash
./Tools/release.sh status
./Tools/release.sh cut 1.1.0 --push          # release/1.1.0, version 1.0.2 -> 1.1.0
./Tools/release.sh tag --push --notes        # v1.1.0 + GitHub pre-release
./Tools/release.sh build --watch             # beta from v1.1.0 -> TestFlight internal
# QA verifies -> beta group added in ASC
./Tools/release.sh finish                    # PR release/1.1.0 -> develop
```

**B. Release from an older commit** — a PR merged to `develop` yesterday must not go into this release; the RC is the merge of PR #320.
```bash
gh pr view 320 --json mergeCommit -q .mergeCommit.oid   # -> abc1234
./Tools/release.sh cut 1.1.0 --from abc1234 --push
```
Everything after that is identical to scenario A.

**C. Bug found in the RC before the tag** — the fix goes to `develop` first (PR #325), then into the release branch.
```bash
git checkout release/1.1.0
./Tools/release.sh pick 325 --push           # cherry-picks the merge commit of #325
./Tools/release.sh tag --push --notes        # tag the fixed head
./Tools/release.sh build --watch
```
Several fixes at once: `pick 325 326 327`. Plain SHAs work too: `pick 9f3e2a1`.

**D. Bug found after the tag (beta already on TestFlight)** — `v1.1.0` stays where it is; the fix ships as a patch from a hotfix branch (the branch name must equal the version, so `release/1.1.0` is not re-bumped).
```bash
./Tools/release.sh hotfix 1.1.1 --from v1.1.0 --push
./Tools/release.sh pick 331 --push
./Tools/release.sh tag --push --notes        # v1.1.1
./Tools/release.sh build --watch
./Tools/release.sh finish                    # hotfix/1.1.1 -> develop
```

**E. Hotfix for the shipped version while the next release is already in progress** — `release/1.2.0` exists, testers run `v1.1.0`.
```bash
./Tools/release.sh hotfix 1.1.1 --from v1.1.0 --push
./Tools/release.sh pick 340 --push           # the fix, already merged to develop
./Tools/release.sh tag --push --notes && ./Tools/release.sh build --watch
./Tools/release.sh finish                    # develop gets the fix; release/1.2.0 picks it separately if needed:
git checkout release/1.2.0 && ./Tools/release.sh pick 340 --push
```

**F. Cherry-pick conflict**
```
❌ Cherry-pick of 9f3e2a1 failed — resolve conflicts, 'git cherry-pick --continue', then re-run for the remaining refs
```
Resolve the files, `git add`, `git cherry-pick --continue`, then run `pick` again for the refs that were not applied yet, and push.

**G. Beta build refused by CI**
```
::error::beta flavor must be built from a tag (vX.Y.Z), got branch 'release/1.1.0'
::error::tag 'v1.1.0' does not match MARKETING_VERSION 1.0.2
```
First message: run the workflow on the tag, not on the branch (`release.sh build` always does). Second: the tag points at a commit without the version bump — never move the tag; cut the next patch version with the bump in place.

**H. Wrong tag pushed** — do not delete it. Fix whatever was wrong on the branch, then `hotfix X.Y.(Z+1) --from vX.Y.Z` or bump on the branch and tag the next patch version.

**I. Where are we?**
```bash
./Tools/release.sh status
```
Shows whether the current version is already tagged and the last five Generate IPA runs with their result and trigger (push/workflow_dispatch).

## For developers: local backend selection

Per-environment configs live in `amplify_configs/{dev,test}/amplifyconfiguration.json`
(gitignored — the repo is public). Get them either with `update_amplify.sh -e dev`
/ `-e test` (needs AWS access; the script stores the pulled config in the right
folder) or from a teammate. Then pick the environment for Debug/QA builds:

```bash
./Tools/select_env.sh dev     # or test — writes amplify_configs/backend_env.txt
```

Release builds always use `test`, whatever the file says. CI fills the same
folder from repository secrets (`AMPLIFY_CONFIG_DEV_B64` / `AMPLIFY_CONFIG_TEST_B64`).

## CI quality gate
SwiftLint runs in `--strict` mode; any violation fails the pipeline before
the build starts (on PRs into `develop`, `release/*`, `hotfix/*`, and on
distribution builds). PRs into release and hotfix branches also run the unit tests.

## One-time GitHub settings (maintainer)
- Settings → Tags → Protected tags: pattern `v*` — tags cannot be deleted or re-pointed.
- Settings → Branches → rule for `release/**` and `hotfix/**`: changes via PR only, required check "Unit Test".

## Where this document lives

This file is the source of truth for the process and changes in the same PR as
`Tools/release.sh`. The Confluence page "Animeal iOS — Build Flavors & Distribution"
is a published copy; when updating it, note the commit this file was copied from.

---
name: animeal-release
description: Release and version management for animeal_iOS — the only skill that touches MARKETING_VERSION. Cut a release/X.Y.Z branch from develop (bumps the version), cherry-pick fixes into it, tag vX.Y.Z, trigger the beta (TestFlight) build on the tag, start a hotfix from a shipped tag, and open the merge-back PR into develop. All logic lives in Tools/release.sh; this skill asks the open questions, proposes a plan and gates every push / tag / CI trigger behind explicit confirmation.
allowed-tools:
  - Bash
  - AskUserQuestion
triggers:
  - bump version
  - new version
  - what version
  - cut a release
  - release branch
  - new release
  - tag the release
  - beta build
  - hotfix
  - animeal release
  - merge back
---

# animeal-release — cut, tag, build and close out a release

The flow (full process, command reference and scenarios: `docs/release-process.md` — read it first when unsure):

```
develop ──cut──▶ release/X.Y.Z ──tag──▶ vX.Y.Z ──build──▶ beta (TestFlight)
                     ▲   │
         pick (fixes)┘   └──finish──▶ PR back into develop
```

`Tools/release.sh` validates every precondition itself (clean tree, version ordering, branch/tag uniqueness, version ↔ branch-name match, branch pushed before tagging, tag on origin before building). **Report its errors verbatim and stop — never work around them** with raw git.

## Step 0 — Orient

Always start with:
```bash
./Tools/release.sh status
```
It prints the project version, current branch, release/hotfix branches on origin, latest tags, and recent `Generate IPA` runs. Use it to pick the right command below and to tell the user where things stand before changing anything.

## Step 0.5 — Intake: questions first, then a plan

The user normally states a goal ("we want to send this to beta testers", "the testers need the crash fix"), not a command. Do not jump to executing. After `status`, collect every open decision in **one** AskUserQuestion (only the questions that are actually open — skip what the user already said):

- **Version** — recommended default first (next minor for a release, next patch for a hotfix), alternatives after it.
- **Start point** — latest `origin/develop` by default; ask only if the user hints that a merged PR must not go into this release (then list the last merged PRs from `git log origin/develop --merges --oneline -5` and cut with `--from` the commit before it). Nobody commits to `develop` directly, so "unfinished work on develop" is not a case.
- **Fixes to cherry-pick** — list candidate PRs merged to `develop` since the release branch was cut, if a release branch already exists.
- **GitHub release notes** — `--notes` yes/no (default yes): a GitHub Releases entry for the tag, marked pre-release, with the list of PRs merged since the previous tag. Free changelog for QA/testers; unrelated to App Store.
- **Ship now?** — whether to go straight through tag + build, or stop after the branch is cut.

Then present the resulting plan as the exact command sequence, e.g.:

```
1. release.sh cut 1.1.0 --from <sha of PR #320>   → push
2. release.sh pick 325 326                        → push
3. release.sh tag --push --notes
4. release.sh build --watch
5. (after QA approval) release.sh finish
```

Execute only after the user confirms the plan; each push / tag / CI trigger / PR is still confirmed separately per the steps below.

## Step 1 — Map the request to a command

| User intent | Command | Confirm first? |
|---|---|---|
| "cut a release", "start 1.1.0", "make RC from develop" | `cut X.Y.Z [--from <ref>]` | version choice if not given (see below) |
| "cherry-pick #312 into the release", "bring the fix to 1.1.0" | `pick <sha\|PR#> [...]` | no (local only) |
| "tag it", "tag the release", "vX.Y.Z" | `tag` | **yes** — tags are effectively immutable once pushed |
| "build beta", "send RC to TestFlight" | `build [X.Y.Z] [--watch]` | **yes** — kicks off CI + TestFlight upload |
| "hotfix on top of 1.0.3" | `hotfix X.Y.Z --from vA.B.C` | version choice if not given |
| "merge back", "release is done", "close the release" | `finish` | **yes** — opens a PR on GitHub |
| "how's the release going", "status", "what version are we on" | `status` | no |
| "bump the version", "new version" | `status`, then ask: release or hotfix? → `cut` / `hotfix` (the bump is part of them) | yes |

**Choosing the version for `cut`/`hotfix`** when the user did not name one: propose the next **minor** for a regular release (`1.0.2 → 1.1.0`) and the next **patch** for a hotfix (`1.0.3 → 1.0.4`). Ask via AskUserQuestion with the proposal as the first option and the alternative bump(s) as the others. A **major** bump always requires the user to say so explicitly.

**Version bumps happen only inside `cut` and `hotfix`.** A bare `./Tools/bump_version.sh X.Y.Z` is allowed in exactly one case: fixing a wrong version on a `release/*` / `hotfix/*` branch that is not pushed yet, and only when the user asks for it explicitly. Never bump on `develop` or on a feature branch — `tag` will refuse it anyway because the version must equal the branch name.

`pick` accepts PR numbers — it resolves the merge commit via `gh`, so prefer PR numbers over SHAs when the fix was merged to `develop` through a PR. Run `pick` **on the release branch** (check `git branch --show-current`; check it out if needed). If a cherry-pick conflicts, the script stops: show the conflicting files, let the user resolve, then `git cherry-pick --continue` and re-run `pick` for any remaining refs.

## Step 2 — Pushing (explicit approval only)

Nothing in `release.sh` reaches origin without `--push`. Per the global git rules, **never push on your own**: after `cut`, `pick` or `tag` succeed locally, ask via AskUserQuestion — **Push to origin** / **Keep local** — and only then re-run the same command's push step:

```bash
git push -u origin release/X.Y.Z      # after cut / pick  (or: release.sh cut ... --push when pre-approved)
./Tools/release.sh tag --push      # after local tag was reviewed
./Tools/release.sh tag --push --notes   # also creates a GitHub pre-release with generated notes
```

`tag` refuses to run until the branch head is on origin — that is intentional: CI builds from the remote tag.

## Step 3 — Beta build

```bash
./Tools/release.sh build X.Y.Z --watch
```
Triggers `Generate IPA` on `vX.Y.Z` with `environment=test` and `qa_menu=off` (Release configuration; the workflow rejects a tag that does not match `MARKETING_VERSION`). Any other combination can be run by hand from GitHub Actions — see "Which build do I get?" in `docs/release-process.md` — but the build for beta testers is only this one. With `--watch` it blocks until the run finishes and reports success/failure; without it, print the run URL. Remind the user of the two remaining manual steps that live in App Store Connect and cannot be automated here:

1. QA verifies the build from the **internal** TestFlight group (this is the RC check on the `test` backend).
2. Once approved, the **external beta** group is added to that build in App Store Connect.

## Step 4 — Close out

Once the build is approved, run `finish` (with confirmation) to open the merge-back PR `release/X.Y.Z → develop`. This is what carries the version bump and cherry-picked fixes back into `develop`; skipping it leaves `develop` with a stale `MARKETING_VERSION`. The PR is reviewed and merged by the user — never merge it yourself.

## Worked example

User: *"I want to hand the current develop to the beta testers"*

1. Run `./Tools/release.sh status` and report: version 1.0.2, no release branches, no tags, last Generate IPA run on `develop` succeeded 2 days ago.
2. One AskUserQuestion:
   - Version: **1.1.0 (recommended)** / 1.0.3 / other
   - Release notes on GitHub: **yes** / no
   - Go all the way to the beta build now: **yes** / stop after the branch is cut
   (no start-point question — the user said "current develop").
3. User picks 1.1.0 / yes / yes. Show the plan:
   ```
   1. ./Tools/release.sh cut 1.1.0            → push release/1.1.0
   2. ./Tools/release.sh tag --push --notes   → v1.1.0
   3. ./Tools/release.sh build --watch        → beta on TestFlight (internal)
   4. later, after QA approval: ./Tools/release.sh finish
   ```
4. User says "yes". Run step 1, confirm the push, run step 2 (confirm), step 3 (confirm), then report the TestFlight build and the two manual ASC steps. Remind about `finish` once QA approves.

## Rules

- Never create release/hotfix branches, tags, or bumps with raw git or by editing `project.pbxproj` — always through `release.sh` so validation runs.
- Never delete or move a tag that has been pushed. If a tag is wrong, cut the next patch version.
- Never point a beta build at the `dev` backend and never run experimental testing against `test` — real beta testers in Georgia use it.
- Never merge to `develop` or force-push anything.
- Work on `release/*` and `hotfix/*` only through `pick` and the bump; feature work still goes to `develop` via PRs.

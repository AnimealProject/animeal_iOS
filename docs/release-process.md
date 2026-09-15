# Animeal iOS — Build Flavors & Distribution

Source of truth: this file. The Confluence copy notes the commit it was taken from.

## Two builds

| | **QA build** | **Beta build** |
|---|---|---|
| Who | developers, QA | real beta testers in Georgia |
| Backend | `dev` (switchable to `test`) | `test` — our de-facto production |
| Built | automatically on every merge to `develop` | from a release tag via `./Tools/release.sh build` |
| Looks | red "QA" ribbon on the icon, name "Animeal QA" | regular icon and name |
| QA menu (More tab) | yes: backend switcher, feature toggles | no |
| TestFlight | internal group, automatically | internal group first, then the beta group is added in App Store Connect |

**Never create test data on `test`.** Experiments belong on `dev`, which is where the QA build points by default.

## Which build do I get?

| Action | Backend | QA menu | Configuration |
|---|---|---|---|
| Merge a PR into `develop` | dev | yes | QA |
| Actions → Generate IPA → Run workflow (any ref) | your choice: `environment` dev/test | your choice: `qa_menu` on/off | QA if the menu is on, Release if off |
| `./Tools/release.sh build X.Y.Z` (tag `vX.Y.Z`) | test | no | Release |

Only the last row goes to beta testers. A Release build from a tag must match `MARKETING_VERSION` (`v1.0.3` ↔ `1.0.3`) or CI fails; from a branch it builds with a warning and is for internal checks only.

The QA menu exists only when the `QA_MENU` compilation condition is set: QA configuration (`QA.xcconfig`) and Debug. Release never sets it.

## Switching backend in the QA build

More → QA Menu → Environment (dev / test). Switching signs you out, clears local data and closes the app; the next launch runs against the selected backend. The menu always shows the active backend and its AppSync host.

## Versioning

| | Example | Changes when |
|---|---|---|
| Marketing version | `1.0.3` | once per release, by `release.sh cut` / `hotfix` — never per commit |
| Build number | `20260906.131` | every CI build, automatically |
| Tag | `v1.0.3` | once, when the RC is approved for a beta build |

Three numbers only (Apple rejects a fourth). While work lands in `develop`, the version stays put and only the build number grows. A release is +minor (`1.0.3 → 1.1.0`), a hotfix is +patch. A pushed tag is never moved or deleted — if a build is bad, ship the next patch version.

## Release flow

```
develop ──cut──▶ release/X.Y.Z ──tag──▶ vX.Y.Z ──build──▶ beta (TestFlight)
                     ▲   │
         pick (fixes)┘   └──finish──▶ PR back into develop
```

Every step is a `./Tools/release.sh` command (`--help` lists them all); in Claude Code, `/animeal-release` walks you through it. The script checks its preconditions and never pushes without `--push`.

```bash
./Tools/release.sh cut 1.1.0 --push          # branch release/1.1.0 from develop, version bumped
./Tools/release.sh tag --push --notes        # v1.1.0 + GitHub pre-release with generated notes
./Tools/release.sh build --watch             # beta build → TestFlight internal group
# QA verifies on the test backend → beta group added in App Store Connect
./Tools/release.sh finish                    # PR release/1.1.0 → develop (version bump + fixes)
```

**A fix is needed before the tag.** Merge it to `develop` as usual, then bring it over and continue:
```bash
git checkout release/1.1.0
./Tools/release.sh pick 325 --push           # PR number or commit sha
```

**A fix is needed after the tag.** The tag stays; ship a patch from the tag:
```bash
./Tools/release.sh hotfix 1.1.1 --from v1.1.0 --push
./Tools/release.sh pick 331 --push
./Tools/release.sh tag --push --notes && ./Tools/release.sh build --watch
./Tools/release.sh finish
```

Don't skip `finish`: without it `develop` keeps the old version. `./Tools/release.sh status` shows where things stand at any moment.

## For developers: local backend

Per-environment configs live in `amplify_configs/{dev,test}/amplifyconfiguration.json` (gitignored — the repo is public). Get them with `update_amplify.sh -e dev` / `-e test` (needs AWS access) or from a teammate, then:

```bash
./Tools/select_env.sh dev     # or test — Debug/QA builds use it, Release builds use what CI selects
```

## CI and GitHub settings

- SwiftLint runs in `--strict` mode and fails the pipeline on any violation; PRs into `develop`, `release/*` and `hotfix/*` also run the unit tests.
- Once, in repository settings: protect tags `v*` (no delete / re-point) and require PRs + the Unit Test check on `release/**` and `hotfix/**`.

---
name: animeal-version
description: Bump the app marketing version (MARKETING_VERSION) for animeal_iOS via Tools/bump_version.sh — patch (default), minor, major (requires user confirmation), or an explicit X.Y.Z. Commits the bump on a dedicated branch. Build number is managed separately by Tools/update_build_number.sh.
allowed-tools:
  - Bash
  - AskUserQuestion
triggers:
  - bump version
  - bump the version
  - new app version
  - animeal version
---

# animeal-version — bump the app marketing version

All logic lives in `Tools/bump_version.sh` — this skill only translates intent and handles confirmation.

1. Map the user's request to an argument: `patch` (default when unspecified), `minor`, `major`, or an explicit `X.Y.Z`.
2. If the bump changes the **first** number (major, or an explicit version with a different major), ask the user first via AskUserQuestion (**Yes, bump major** / **Cancel**). On Cancel, stop.
3. Run:
   ```bash
   bash Tools/bump_version.sh <arg>          # confirmed major: add --yes
   ```
   The script validates everything itself (consistency across configurations, exact replacement count) and fails loudly — report its errors to the user verbatim, do not work around them.
4. Commit `animeal.xcodeproj/project.pbxproj` on a branch `feature/bump_version_<X_Y_Z>` (create it off up-to-date `develop` if not already on a dedicated branch) with message `Bump version to <X.Y.Z>`. Do not push unless asked.

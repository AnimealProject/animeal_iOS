# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Policy

Regardless of the language used in conversation, **all code comments, instructions, hook messages, and inline documentation must be written in English**.

## Commands

### Build & Test

Before running tests, detect the best available simulator — prefer booted, fall back to latest available iPhone:

```bash
# Detect best simulator
DEST=$(python3 -c "
import subprocess, json, sys
data = json.loads(subprocess.check_output(['xcrun', 'simctl', 'list', 'devices', 'available', '-j']))
iphones = [(r, d) for r, devs in data['devices'].items() for d in devs if d['isAvailable'] and 'iPhone' in d['name']]
booted = [x for x in iphones if x[1]['state'] == 'Booted']
best = sorted(booted or iphones, key=lambda x: x[0], reverse=True)
if not best:
    print('NONE')
else:
    r, d = best[0]
    print(f\"platform=iOS Simulator,name={d['name']}\")
")
if [ "$DEST" = "NONE" ]; then
  echo "❌ No iOS simulator found. Install one via Xcode → Settings → Platforms"
  exit 1
fi

# Build and run tests
xcodebuild test -scheme animeal -project animeal.xcodeproj \
  -destination "$DEST" -parallelizeTargets 2>&1 | xcbeautify
```

```bash
# Run SwiftLint
make swiftlint
# or directly:
PROJECT_DIR=`pwd` ./Tools/swiftlint.sh

# Regenerate Amplify models from backend schema (will ask permission via hook)
amplify codegen models

# Regenerate localization strings (requires swiftgen)
swiftgen

# Setup/update Amplify — REQUIRES credentials (will ask permission via hook)
bash ./update_amplify.sh -a $AWS_ACCESS_KEY_ID -s $AWS_SECRET_ACCESS_KEY \
  -i $APP_ID -e $AMPLIFY_DEV_ENV -t $FACEBOOK_APP_ID -r $FACEBOOK_APP_SECRET
# If that fails:
bash ./recover_from_error.sh
```

> **Amplify hook**: Every `amplify` command is blocked by `.claude/hooks/amplify-guard.sh`. When blocked:
> 1. Use `AskUserQuestion` with two options — **Approve** / **Deny** — so the user sees a menu, not a text prompt
> 2. If approved, re-run the command with `# approved` appended (e.g. `amplify codegen models # approved`)
> 3. If denied, skip the command and inform the user

### Mapbox Setup (first time)
```bash
echo $MAPBOX_DOWNLOAD_TOKEN >> ~/.mapbox
```

## Architecture

**MVVM + Flow Coordinator** pattern throughout.

### Module Structure
Each feature module follows this contract:
```
SomeFeature/
├── SomeFeatureAssembler.swift    # DI wiring: Model → ViewModel → ViewController
├── SomeFeatureContract.swift     # Protocol definitions for View/ViewModel/Model layers
├── SomeFeatureViewModel.swift    # Business logic, drives view via closure callbacks
├── SomeFeatureViewController.swift
└── Model/
    ├── SomeFeatureModel.swift    # Data fetching, domain logic
    └── UseCases/                 # Single-responsibility use case objects
```

**Contract pattern**: Each module defines its interfaces in a `*Contract.swift` file with protocol typealias combinations (e.g. `typealias FooCombinedViewModel = FooLifeCycle & FooInteraction & FooState`). The Model protocol is annotated with `// sourcery: AutoMockable` to generate mocks via Sourcery.

**ViewModel → View communication**: Via closure callbacks (`var onSomethingHappened: ((Data) -> Void)?`), not Combine publishers at the view layer.

### App Layers

```
animeal/src/
├── App/                   # AppDelegate, AppContext (DI container)
├── Flows/                 # Feature flows
│   ├── Auth/              # Login, phone verification, profile setup
│   ├── Main/              # Tab bar with 5 tabs:
│   │   ├── Modules/Home/  # Map view, feeding point selection, feeding flow
│   │   ├── Modules/Search/
│   │   ├── Modules/Favourites/
│   │   ├── Modules/Leaderboard/
│   │   └── Modules/More/  # Settings, donate, FAQ, etc.
│   ├── Profile/           # Profile editing
│   └── AttachPhoto/       # Camera/photo for finishing a feeding
├── Business/
│   ├── Networking/        # NetworkService (Amplify GraphQL), NetworkRequest.swift (Request<T> extensions), NetworkRequestModels.swift (raw GQL documents)
│   └── Services/          # Domain services injected via AppContext
└── Navigation/            # Coordinatable protocol, Navigator
```

### Dependency Injection
`AppContext` (in `animeal/src/App/AppContext.swift`) is the service locator. Services are accessed via `AppDelegate.shared.context`. All services are protocol-backed and defined in `AppContext` via protocol composition (`AppContextProtocol`).

**Guest mode**: `FeedingPointsServiceAdapter` transparently switches between `MockFeedingPointsService` (guest) and `FeedingPointsService` (authenticated) based on user mode.

### Swift Package Modules (local SPM packages)

This is a **package-based project**. When adding or modifying code, verify it belongs to the correct package. Placing app-level code in an SPM package (or vice versa) is a common mistake.

| Package | Contents | Allowed dependencies |
|---|---|---|
| `Common` | Shared utilities, base errors, extensions | none |
| `Services` | `NetworkServiceProtocol`, logging, Firebase Crashlytics/Analytics | CocoaLumberjack, Firebase |
| `Style` | Colors, fonts, image assets (`Assets.swift` — generated, do not edit) | none |
| `UIComponents` | Reusable UI components | Style, Common, Kingfisher |
| `animeal` (app target) | All feature flows, business services, AppContext | All packages above + Amplify, MapBox |

Rules:
- SPM packages must not import `animeal`-only types (e.g. `AppDelegate`, `AppContext`)
- `Common` and `Style` have no internal dependencies — keep them that way
- `UIComponents` must not depend on `Services` or any networking/backend code

### Networking Layer
Two `NetworkServiceProtocol` implementations:
- `NetworkService` — authenticated (Cognito user pools)
- `PublicNetworkService` — guest/API key auth

Custom GraphQL queries are written as raw document strings in `NetworkRequestModels.swift` with `Request<ResponseType>` wrappers. Add `Request` extension methods in `NetworkRequest.swift`. The `decodePath` parameter tells Amplify where in the response JSON to decode.

### AWS Amplify / Backend
- **DataStore** (`DataStoreService`) — offline-capable sync for Amplify models
- **GraphQL API** (`NetworkService`) — direct API calls bypassing DataStore; used for custom Lambda-backed queries
- Generated models live in `amplify/generated/models/` — do not edit manually; regenerate with `amplify codegen models`
- Custom resolvers (Lambda) are in `amplify/backend/custom/`
- The iOS and Android apps share the same AWS backend

### Localization
Strings managed via SwiftGen. Edit `animeal/res/en.lproj/Localizable.strings`, then run `swiftgen` to regenerate `animeal/src/Common/Strings.swift` (which is auto-generated — do not edit directly).

The source of truth for all translated copy (English + Georgian) is an external spreadsheet maintained by the team, not this repo — its link is intentionally not recorded here to avoid exposing it in the codebase. Ask the user for it if you need to check or add a translation.

**Rule:** never hardcode a new user-facing string directly in Swift, and never speculatively add a new key to `Localizable.strings` on your own. If a change needs new UI copy that has no existing `L10n.*` key:
1. Flag it to the user and propose the exact key + English text to add to the translations spreadsheet.
2. Only after it's confirmed added there, add the matching key to `Localizable.strings` and regenerate with `swiftgen`.

### Testing
- **Currently there are no unit tests** — test coverage will be added soon
- Framework: **Apple Testing** (`import Testing`) — do NOT use Quick or Nimble
- Mocks are auto-generated by Sourcery into `animealTests/Sourcery/Generated/AutoMockable.generated.swift`; mark protocols with `// sourcery: AutoMockable` to include them
- **Never edit `AutoMockable.generated.swift` manually.** After changing a protocol marked `AutoMockable`, regenerate:
  ```bash
  cd animealTests/Sourcery && ./sourcery --config sourcery.yml
  ```
- UI tests: `animealUI/`

### CI
- `unit-test.yml` — runs SwiftLint (`--strict`) + builds + tests on PRs to `develop`, `release/**`, `hotfix/**`
- `GenerateIPA.yml` — QA build (dev backend, QA menu) on every merge to `develop`; manual runs choose `environment` (dev/test) and `qa_menu` (on/off); the beta build is `test` + menu off from a tag `vX.Y.Z` matching `MARKETING_VERSION`; uploads to TestFlight

## Release & versioning — offer the skill proactively

One project skill, `animeal-release`, owns everything about versions, release branches, tags,
hotfixes and beta builds (`./Tools/release.sh`: status / cut / pick / tag / build / hotfix / finish).
The process is documented in `docs/release-process.md`. The user will usually state a goal, not a
command — whenever the conversation touches any of this, **offer `/animeal-release` yourself**:

| User says something like | Offer |
|---|---|
| "release", "RC", "cut a branch", "send to beta testers", "TestFlight beta", "ship it" | `/animeal-release` |
| "tag", "vX.Y.Z", "hotfix", "fix for testers", "patch the beta" | `/animeal-release` |
| "bump", "new version", "what version are we on" | `/animeal-release` (the bump is part of cut / hotfix) |
| "merge back", "release is done", "develop still says 1.0.2" | `/animeal-release finish` |

Behaviour once the skill is on:
1. `./Tools/release.sh status` first; show the state (version, branches, tags, last builds).
2. One AskUserQuestion with only the open decisions: target version (recommended default first), fixes to cherry-pick, GitHub release notes yes/no, go to the beta build now or stop after the cut.
3. Present the exact command sequence as a plan; execute only after an explicit "yes". Every push, tag, CI trigger and PR is confirmed separately.

`MARKETING_VERSION` changes only inside `cut` / `hotfix`. Never run raw `git tag`, `git branch release/...` or edit the version in `project.pbxproj` by hand.

## Architecture & Conventions

Before creating new UI components, screens, or services — search the existing codebase
for patterns to follow:

- UI components: `animeal/src/Common/Views/`
- Design tokens (colors, fonts, spacing): check `DesignSystem` module
- Navigation: `AnimealCoordinator` pattern — do not use direct NavigationLink
- Dependency injection: constructor injection via `@DIAssembly`

When in doubt, find an existing similar component and follow the same pattern.
Architecture decisions will be documented in `docs/` as the project evolves.

### Android Sibling Repository
This app has an Android twin sharing the same backend: https://github.com/AnimealProject/animeal_android. When comparing implementations, resolving ambiguity about intended behavior, or in doubt about a UI/architecture decision, check the Android repo for how it solved the same problem.

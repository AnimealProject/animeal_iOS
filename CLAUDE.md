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

### Testing
- **Currently there are no unit tests** — test coverage will be added soon
- Framework: **Apple Testing** (`import Testing`) — do NOT use Quick or Nimble
- Mocks are auto-generated by Sourcery into `animealTests/Sourcery/Generated/AutoMockable.generated.swift`; mark protocols with `// sourcery: AutoMockable` to include them
- UI tests: `animealUI/`

### CI
- `unit-test.yml` — runs SwiftLint + builds + tests on PRs to `develop`
- `GenerateIPA.yml` — builds IPA on merge to `develop`, deploys via Firebase App Distribution

## Architecture & Conventions

Before creating new UI components, screens, or services — search the existing codebase
for patterns to follow:

- UI components: `animeal/src/Common/Views/`
- Design tokens (colors, fonts, spacing): check `DesignSystem` module
- Navigation: `AnimealCoordinator` pattern — do not use direct NavigationLink
- Dependency injection: constructor injection via `@DIAssembly`

When in doubt, find an existing similar component and follow the same pattern.
Architecture decisions will be documented in `docs/` as the project evolves.

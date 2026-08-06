---
name: animeal-review
description: Independent code review for animeal_iOS — reviews a GitHub PR (pass a PR number/URL), uncommitted local changes, or unpushed local commits (auto-detected when no argument is given; always announces which mode it's running in). Structured critical-issue pass (GraphQL/Amplify safety, Swift concurrency races, SwiftUI property-wrapper correctness, enum completeness, auth) plus parallel specialist subagents (testing, maintainability, security) plus a mandatory adversarial "think like an attacker" pass plus a localization check, then cross-references GitHub Copilot's PR review where applicable. Report-only — never auto-fixes. Self-contained, no external tooling required.
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
triggers:
  - review this pr
  - code review
  - check my diff
  - animeal review
---

# animeal-review

Independent, structured code review for this repo, run before merging to `develop`. The mix of steps below is deliberate, based on comparing what different review strategies are actually good at:

- A **generic reviewer without a checklist** catches conventions and obvious issues fast, but has nothing prompting it to specifically look for concurrency/race-condition bugs, so those are easy for it to miss.
- **Checklist-driven specialists** (testing/maintainability/security) catch categories a generic pass can miss, at the cost of being more expensive per finding.
- An **adversarial "think like an attacker and chaos engineer" pass with no checklist at all** is included because unconstrained review sometimes surfaces things a fixed category list doesn't prompt for. Treat it as mandatory, never optional — it's cheap insurance, not a step to skip for speed.
- **GitHub Copilot's PR review**, when available, is a free additional quality gate — an independent second opinion with no shared bias with the passes above, not because it's specifically stronger at any one category. Use it if it's available (or offer it to the user as an option) rather than skipping it, but treat any given category-specific strength as anecdotal until seen repeatedly, not as an established fact to build the workflow around.

This skill reproduces that mix without requiring any external tool — every step below is either a direct Bash/Grep/Read check or a subagent dispatched via the `Agent` tool.

## Step 0 — Setup

This skill reviews one of three possible scopes. Pick the scope with the logic below, then **tell the user which mode you're running in before doing anything else** — a report that silently reviewed the wrong thing (e.g. only committed history when the user actually wanted eyes on their uncommitted work) is worse than no report.

**Scope selection:**

1. **PR mode** — if the skill was invoked with an argument (e.g. `/animeal-review 301`, `/animeal-review #301`, `/animeal-review https://github.com/.../pull/301`) that looks like a PR reference (a bare number, `#123`, `PR 123`, or a URL containing `/pull/`), review that PR directly, regardless of local working-tree state:
   ```bash
   PR_NUM=<extracted number>
   gh pr view "$PR_NUM" --json baseRefName,headRefName,url -q '{base: .baseRefName, head: .headRefName, url: .url}'
   gh pr diff "$PR_NUM" > /tmp/animeal-review-diff.patch
   ```
   `gh pr diff` fetches the diff directly from GitHub without checking out the branch or touching the local working tree — use this diff for every later step instead of `git diff "$DIFF_BASE"`. Report: `Mode: PR review — #<PR_NUM> (<head> → <base>)`.

2. **No argument given** — inspect local state, in this priority order:
   ```bash
   git status --porcelain
   ```
   - **Uncommitted-changes mode**: if this has any output (staged, unstaged, or untracked files), review the working tree, not history:
     ```bash
     git diff HEAD          # staged + unstaged changes to tracked files
     git status --porcelain # untracked files — read the new files directly, git diff won't show their content
     ```
     Report: `Mode: uncommitted local changes`. This takes priority over committed-but-unpushed work — if the user has both, they almost always want eyes on the newest, unreviewed thing, which is what's sitting uncommitted.
   - **Local-commits mode**: if the working tree is clean, but the current branch has commits not on the base branch:
     ```bash
     BASE_BRANCH=develop
     git fetch origin "$BASE_BRANCH" --quiet
     DIFF_BASE=$(git merge-base "origin/$BASE_BRANCH" HEAD)
     git branch --show-current
     git diff "$DIFF_BASE" --stat
     ```
     Report: `Mode: local commits — <branch name>, N commits ahead of <BASE_BRANCH>`.
   - **Nothing to review**: working tree clean and no commits ahead of the base branch — say so and stop.

Read `CLAUDE.md` at the repo root before anything else, regardless of mode — every finding below should be checked against its conventions:
- MVVM + Coordinator, the `*Contract.swift` protocol pattern, `// sourcery: AutoMockable` on mockable protocols.
- SPM package boundaries: `Common`/`Style` have zero internal dependencies; `UIComponents` must not import `Services` or networking; `animeal`-only types (`AppDelegate`, `AppContext`) must not leak into packages.
- New code uses `@Observable`, not `ObservableObject`.
- Zero code comments by default — only when the WHY is genuinely non-obvious (a hidden constraint, a workaround). Never a comment restating what the code does.
- Never hardcode a new user-facing string; new copy needs an `L10n.*` key added via the translations spreadsheet + `swiftgen`, not invented ad hoc in Swift or added speculatively to `Localizable.strings`.
- When behavior is ambiguous, the Android sibling repo (`AnimealProject/animeal_android`) is the reference implementation.

## Step 1 — Scope check (quick, informational)

Skip this step entirely in **uncommitted-changes mode** — there's no commit history to sanity-check yet.

In **PR mode** or **local-commits mode**:
```bash
git log "origin/$BASE_BRANCH..HEAD" --oneline   # local-commits mode
# or, in PR mode:
gh pr view "$PR_NUM" --json commits -q '.commits[].messageHeadline'
```

Skim commit messages against what the PR title/description (or, locally, the stated task) claims. This repo's PRs sometimes intentionally bundle unrelated fixes to save time (a known, accepted practice here) — don't flag bundling itself as a problem, just make sure every commit's *content* still gets reviewed on its own merits, not skipped because it looks unrelated to the main feature.

## Step 2 — Structured critical pass (run this yourself, not a subagent)

Read the diff you obtained in Step 0 (the `.patch` file in PR mode, `git diff HEAD` in uncommitted mode, `git diff "$DIFF_BASE"` in local-commits mode) and check each category below. Cite `file:line`, be terse, skip anything that's fine.

### GraphQL / Amplify data safety
- A `document: String` (in `NetworkRequestModels.swift` or similar) interpolates a variable directly into the mutation/query text instead of using `variables` — CRITICAL if that value can contain `"`, `\`, or a newline, especially free user text (`TextEditor`, an alert text field).
- `QueryPredicateOperation`/`QueryPredicateGroup` — right field/operator/`.and`/`.or`; sort/max-by happens client-side after fetch (this SDK has no server-side sort).
- New Amplify model field added to a document selection but never consumed.

### Swift concurrency & state races
- Async action from a button/gesture sets an in-flight flag (`isProcessingAction`, `isLoading`) but has no `guard !flag else { return }` at entry — re-entrancy, not just a UI overlay a render-frame later.
- State reloaded from more than one call site with no generation token/cancellation — an older response can overwrite a newer one.
- `withTaskGroup` results consumed assuming submission order — `for await item in group` yields completion order only; preserve order via a stable key or a sequential loop inside one task.
- Fire-and-forget `Task {}` outside a one-shot tap handler, with no stored handle and no cancellation where one is needed (view disappearing, a newer call superseding it). Prefer `.task { }` over `.onAppear { Task { ... } }` — `.task` cancels automatically on disappear.
- UI-facing `@Observable`/`ObservableObject` state mutated from a background context without `@MainActor`.
- Mutable reference type (a `class` without synchronization) crossing a `Task`/actor boundary — `Sendable` risk even if the compiler doesn't flag it.

### Memory management
- Escaping closure (stored property, completion handler) captures `self` strongly instead of `[weak self]` — short, synchronous closures (most SwiftUI builders/button actions) are the exception, they don't need it.
- `protocol X: AnyObject` delegate property not declared `weak`.
- `unowned` used where the referenced object isn't actually guaranteed to outlive the reference — should be `weak`.

### SwiftUI property wrappers
Each wrapper is an ownership claim; a mismatch is a class of bug, not a one-off. Check every wrapper touched in the diff:

| Wrapper | Correct when | Misuse to flag |
|---|---|---|
| `@State` | view-local value, view owns it | `@State var x` never mutated after init → should be `let`; or the view sits in a `List`/`ForEach` row and keeps a stale first-render value once the parent starts passing fresh data to the same row identity |
| `@Binding` | child must mutate a value a parent owns | used for a value the view should own itself, or for a one-way/constant value that should just be a parameter |
| `@StateObject` | view creates/owns the object's lifetime | `@ObservedObject` used here instead → object recreated and reset on every parent re-render |
| `@ObservedObject` | object owned elsewhere, passed in | `@StateObject` used here instead → creates a second, disconnected instance |
| `@Environment` / `@EnvironmentObject` | reads a value injected by an ancestor | view constructs its own default instance instead — silently ignores whatever was injected above it |
| `@FocusState` | drives focus transitions | declared but never updated on submit/validation/tab-switch |
| `@AppStorage` / `@SceneStorage` | small, non-sensitive, UI-scoped preference | used for sensitive/large data, or state that needs to be mockable in tests |

Also: `ForEach`/`List` row `id` must be a stable identifier from the data, not a positional index — an index-based id causes the same stale-view symptom as a misused `@State` whenever rows are inserted, removed, or reordered.

### Enum & value completeness
When the diff adds a new `case` to an existing enum, or a new raw-value/status string:
- Grep every `switch`/`if case` on that enum type across the repo (not just the diff) and read each match — does the new case fall into an unhandled `default:` that silently produces the wrong UI/behavior?
- Check any allowlist/array of sibling cases (e.g. tab lists, filter arrays) for whether the new case needs adding there too.

### Authorization
- Moderation/write action (approve, reject, delete, role change) gated only by client-side UI state (`status == .pending`, a role check that only controls menu visibility) — flag as unconfirmed unless the backend (Lambda resolver / AppSync `@auth`) independently re-enforces it. Client-side is UX, not a security boundary.

### Accessibility
- Icon-only button/tappable row with no accessibility label — invisible to VoiceOver.
- Hardcoded font size on new text where the design system's font tokens would normally apply — ignores Dynamic Type.
- Custom tap target well under ~44x44pt.

## Step 3 — Localization check (do this yourself; no specialist catches this)

If the diff (from whichever mode Step 0 selected) touches `Localizable.strings`, `sheet.csv`, or adds new `L10n.*` usages, look at what changed in those specific files (`git diff HEAD -- <paths>` in uncommitted mode, `git diff "$DIFF_BASE" -- <paths>` in local-commits mode, or grep the `.patch` file for those paths in PR mode).

- For every changed/added key, read the **English and Georgian values side by side** (`grep -n "the.key" animeal/res/en.lproj/Localizable.strings animeal/res/ka.lproj/Localizable.strings`). Watch for **swapped values between two adjacent keys** — e.g. a dialog's title and its body text landing under each other's key in one language file only, invisible unless you diff both files for the same pair of keys side by side.
- Basic English grammar sanity on new/changed strings — singular/verb-form mistakes are easy to miss when writing quickly (subject-verb agreement, wrong participle form, missing article).
- Any new string hardcoded directly in Swift instead of going through `L10n.*` — flag per the CLAUDE.md rule (propose the key, don't add it to `Localizable.strings` yourself).

## Step 4 — Specialist subagents (parallel, foreground — wait for all before reporting)

Dispatch three subagents via the `Agent` tool in a single message so they run in parallel. Each gets a fresh, independent context — no bias from Steps 2-3. Use `subagent_type: general-purpose` for all three (Bash + Read + Grep access).

Give each of them a way to reproduce the exact same diff Step 0 selected — a subagent has no memory of which mode you're in, so state it explicitly and give the exact command for that mode:
- PR mode: tell it the diff is already saved at `/tmp/animeal-review-diff.patch` and to read that file.
- Uncommitted mode: `` git diff HEAD `` (plus a note to separately check `git status --porcelain` for untracked files, which that diff command won't show).
- Local-commits mode: `` DIFF_BASE=$(git merge-base origin/develop HEAD) && git diff "$DIFF_BASE" ``

Also give each of them: working directory, and a one-line description that this is a Swift/SwiftUI + UIKit iOS app, MVVM+Coordinator, backed by AWS Amplify/AppSync GraphQL with Cognito auth.
- Instruction to output findings as `[SEVERITY] (confidence: N/10) file:line — description, with a one-line fix`. Skip anything that's fine. No preamble, no "looks good overall."

**Testing specialist** — this project currently has very few unit tests, so don't flag "no test for X" as noise against an established suite. Focus on: untested guard clauses/error branches in the new code that are cheap and valuable to test given tests are being added incrementally; concurrency-shaped code (async task groups, state mutated from multiple async contexts) with no isolation; edge cases (empty arrays, nil, zero) in new logic.

**Maintainability specialist** — dead code, unused variables/imports, magic numbers that should be named constants, DRY violations (near-duplicate functions), stale/restating comments (flag for removal per this repo's zero-comment convention), module boundary violations against the CLAUDE.md package rules above. Also, general Swift code quality: force-unwraps (`!`) and `try!` where a safe alternative is straightforward, implicitly-unwrapped optionals (`T!`) outside `@IBOutlet`s, access control wider than needed (default to `private`/`fileprivate`, widen only when actually required elsewhere), and O(n²)-shaped lookups (linear `.contains`/`.first(where:)` inside a loop) that a `Set`/`Dictionary` keyed lookup would make O(n).

**Security specialist** — adapted for a mobile GraphQL client, not a server backend: unescaped user input reaching a GraphQL document (see Step 2), auth/authorization gaps (see Step 2), secrets/tokens in source, unsafe handling of S3-backed storage keys/URLs (path traversal shape), predictable randomness for any token-like value, and anything logged (print/os_log/Crashlytics) that could contain a token, password, or PII.

## Step 5 — Adversarial pass (mandatory — do not skip this to save time)

Dispatch one more subagent, foreground, **with no checklist at all**. Same rule as Step 4 — tell it explicitly which mode you're in and how to get the diff (the saved `.patch` file in PR mode, `git diff HEAD` in uncommitted mode, or `git diff "$DIFF_BASE"` against `git merge-base origin/develop HEAD` in local-commits mode):

> Read the diff with <the mode-appropriate command above>. Think like an attacker and a chaos engineer. Find ways this code will fail in production: edge cases, race conditions (this app uses Swift concurrency heavily — async/await, withTaskGroup, @Observable state, SwiftUI @State/@Binding), security holes, resource leaks, silent data corruption, logic errors that produce wrong results without crashing, error handling that swallows failures. Be adversarial, be thorough, no compliments. For each finding: file:line, what breaks and under what conditions, FIXABLE or INVESTIGATE. End with one line: `Recommendation: <action> because <specific finding>` — the reason must name a concrete finding, not a generic justification.

Empirically this pass alone tends to match or exceed the combined checklist specialists in usefulness — don't treat it as optional padding.

## Step 6 — GitHub Copilot as an optional extra gate

This is an add-on signal, not a step this skill depends on — a free independent second opinion when it happens to be available, folded in if there's anything worth folding in.

Already have `$PR_NUM` from PR mode in Step 0 — use it directly. In uncommitted-changes or local-commits mode, check whether the current branch happens to already have an open PR:

```bash
PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
```

- **No PR number found** (uncommitted-changes mode, or a local-commits branch with no PR yet): nothing to cross-reference. Mention to the user, as an option, that opening a PR would let them additionally request a Copilot review — don't imply this skill is incomplete without it.
- **PR number found**:
  ```bash
  gh api repos/AnimealProject/animeal_iOS/pulls/$PR_NUM/comments --jq '.[] | select(.user.login=="Copilot") | {created_at, path, line, body}'
  gh pr view $PR_NUM --json reviews -q '.reviews[] | select(.author.login=="copilot-pull-request-reviewer") | {submitted_at, state}'
  ```
  If there are Copilot comments **newer than the most recent commit on the branch**, fold their findings into the merged report below (dedupe against your own findings by file/line). If Copilot's review predates the latest commit, or none exists, tell the user: *"No current Copilot review on this PR — you can request one as an extra check before merging."* Do not request it yourself; that's the user's call (visible action on a shared PR).
- If `gh` isn't authenticated, skip this step and say so — don't block the rest of the review on it.

## Step 7 — Merge and report

Combine findings from Steps 2, 3, 4, and 5. Dedupe by `file:line` + issue — if multiple sources found the same bug, say so ("confirmed independently by N sources") and keep the clearest explanation, not the first one. Sort by severity:

```
Review: N issues (X critical, Y informational)

CRITICAL
- [file:line] Problem. Confirmed by: <sources>.
  Fix: <one line>

INFORMATIONAL
- [file:line] Problem. Confirmed by: <sources>.
  Fix: <one line>

Copilot: <status from Step 6>
```

**This skill never auto-fixes.** Report only — the developer decides what to act on and asks for the fix explicitly. Do not create commits, push, or open/comment on the PR as part of this review.

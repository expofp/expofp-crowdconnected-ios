# ExpoFpCrowdConnected PR Review Instructions

Source of truth for automated PR review. `CLAUDE.md` is extra context only; this file wins on conflict.

The project is **`ExpoFpCrowdConnected`** — a small Swift package (3 files, ~350 lines) that adapts the
CrowdConnected SDK to ExpoFP's `IExpoFpLocationProvider`. It is **published** via SPM (and legacy CocoaPods),
so its public API is a contract with consumer apps. There are no tests: review is the only safety net.

Comments must be conservative, actionable, and anchored to the diff.
Do not invent findings. Do not summarize what the PR does. Do not request broad refactoring unless the change
introduces a real correctness or maintainability risk.

---

# Review Priority

1. Public API compatibility (this is a distributed library)
2. Delegate correctness — `CrowdConnectedDelegate` and `CLLocationManagerDelegate`
3. Start/stop lifecycle: timeout task, permission requests, heading updates
4. `ExpoFpCrowdConnectedLocationProviderSettings` validation
5. Dependency versions across `Package.swift`, the podspec and `README.md`
6. Doc comments and README parity for public API changes
7. Scope discipline

---

# Severity

- 🔴 **Must fix** — correctness bugs, retain cycles, unpaired start/stop, silently broken positioning,
  source-breaking public API changes without a version bump, Info.plist key typos in the validator.
- 🟡 **Should consider** — risky behaviour, missing edge cases, missing rationale for behaviour changes,
  docs/README drift.

Style and formatting nits are out of scope.

---

# Review Modes

Selected by the trigger (`.github/workflows/claude-pr-review.yml`): `@claude` → **light** (Sonnet, 35 turns),
`@claude deep` → **deep** (Opus, 50 turns), `@claude [deep] focus: <text>` restricts findings to the named area.
Modifiers must be on the same line as `@claude`; only OWNER/MEMBER may trigger.

**light** — first-pass on newly introduced issues in the diff. Skip speculative and cross-file concerns unless the
PR touches public API, delegate callbacks, or dependency versions.

**deep** — full Review Priority list, plus: threading of delegate callbacks (CrowdConnected fires on a background
thread; ExpoFP delegate consumers expect main-thread updates), `Task`/`[weak self]` capture in the timeout logic,
and whether the CrowdConnected version pin still matches the API being called.

---

# Public API

Everything `public` here ships to consumer apps. Flag 🔴 when a diff renames or changes the signature of
`ExpoFpCrowdConnectedLocationProvider`'s members or the `ExpoFpCrowdConnectedLocationProviderSettings`
initializer without the PR stating a major-version bump. Adding a parameter to the settings `init` is
source-breaking unless it has a default value.

New public members must carry doc comments in the existing style, and any change visible in the README's
Quick Guide must update the README in the same PR (🟡).

---

# Provider correctness

`ExpoFpCrowdConnectedLocationProvider` is both `CrowdConnectedDelegate` and `CLLocationManagerDelegate`.
Flag:

- Changes to the position mapping in `didUpdateLocation` that drop the `location.type == "IPS"` branch, mix pixel
  coordinates with lat/lng, or stop carrying the previous `angle` (heading arrives from a separate delegate, so it
  is lost on every fix otherwise) — 🔴.
- `startUpdatingLocation()` / `stopUpdatingLocation()` losing symmetry: the 65s timeout task must be armed on start
  and cancelled in both `stopTimeoutTask()` paths (`didStartSuccess` and stop), and heading updates must be stopped.
- `Task` closures capturing `self` strongly, or delegate properties made strong (`expoFpLocationProviderDelegate`
  is deliberately `weak`) — 🔴.
- Deriving `isLocationUpdating` from anything other than `CrowdConnected.shared.isRunning` — a local flag can
  desync from the singleton.
- Aliases applied before `didStartSuccess` (no device ID exists yet), or errors reported without the
  `deviceIdDescription` prefix used everywhere else.

# Settings validation

The settings `init` (typed `throws(ExpoFpError)`) is the only guard against a misconfigured host app. Flag:

- Typos or changes to the raw Info.plist key strings (`NSLocationWhenInUseUsageDescription`,
  `NSLocationAlwaysAndWhenInUseUsageDescription`, `NSBluetoothAlwaysUsageDescription`, `UIBackgroundModes`,
  `location`, `bluetooth-central`) — a wrong string silently passes validation and fails at runtime, 🔴.
- Relaxing a check (empty credentials, empty/Bluetooth-only `modules`) without rationale.
- Validation moved out of `init` into a call the consumer can skip.

---

# Dependencies & versions

- `Package.swift` pins `crowdconnected-sdk-swift-spm` with `exact:` — deliberate, since CrowdConnected ships
  binary frameworks. Flag a switch to a range, branch, or revision, and flag a version bump that is not the stated
  subject of the PR.
- `ExpoFpCrowdConnected.podspec` intentionally lags: CocoaPods is frozen at 5.1.5 / CrowdConnected 2.3.0. Do not
  flag the mismatch as a bug; **do** flag a podspec dependency edit that is inconsistent with that (🟡) or a
  `spec.version` that no longer matches the tag being released.
- SPM version bumps must land in `Package.swift`, and — if the README's SPM snippet is stale — the README too
  (`publish.sh` rewrites it at release time).
- New dependencies are almost always wrong: this package exists to stay a thin wrapper.

---

# Scope discipline

Flag drive-by refactors: renaming unrelated types, formatting sweeps, moving code between the three files without
reason, or bumping dependency versions unrelated to the PR title. Logic that belongs in the ExpoFP SDK or in
CrowdConnected should not be reimplemented here — flag 🟡 when a PR adds map/positioning logic beyond adapting one
SDK to the other.

Comments should explain *why* (SDK constraints, the 65s timeout, weak delegate, IPS-vs-geo branching), not restate
the code. Flag comments that only restate the code.

---

# Review Output Format

Publish **one atomic Review object** per run via the GitHub Reviews API — never scattered individual comments.

```bash
gh api repos/{owner}/{repo}/pulls/{N}/reviews \
  -X POST \
  -F event=COMMENT \
  -F body="<top-level summary, 1-3 lines>" \
  -F 'comments[][path]=ExpoFpCrowdConnected/File.swift' \
  -F 'comments[][line]=42' \
  -F 'comments[][body]=...'
```

- Exactly one `gh api .../pulls/N/reviews` call per run, `event=COMMENT` (informational, not a gate).
- Body is short: `"Claude review completed: no new findings."` or `"N findings — see inline comments."`
  A severity-grouped one-line index (`🔴 path:line — short title`) is allowed as navigation for deep reviews;
  never restate inline rationale or paste diffs in the body.
- Each finding is one `comments[]` entry anchored to the exact diff line, formatted as:

````text
🔴 Must fix: <one-sentence problem statement>

```suggestion
<exact replacement for the highlighted lines>
```

<optional one-line rationale>
````

- Severity prefix mandatory. Include a ` ```suggestion ` block whenever a concrete fix exists (content must match
  the highlighted lines exactly); otherwise say in one sentence what would resolve it.
- `mcp__github_inline_comment__create_inline_comment` is a fallback only if the Reviews API call fails.
- Do not post approval-style findings, PR summaries, generic advice, findings about the CrowdConnected or ExpoFP
  SDKs themselves (out of scope — only this wrapper's usage of them), or review text to workflow logs.
- Do not use `gh pr comment` for findings.

---

# Duplicate Comment Avoidance

Before publishing, fetch existing `claude[bot]` reviews and inline comments:

```bash
gh api repos/{owner}/{repo}/pulls/{N}/reviews --paginate
gh api repos/{owner}/{repo}/pulls/{N}/comments --paginate
```

Skip any finding whose `(path, line, severity)` tuple already exists — same path and severity on a **different**
line is a new finding. If everything was already raised, post a Review with empty `comments[]` and the
no-new-findings body. Never repost old findings with "still unaddressed".

If a `claude[bot]` progress marker exists with no final Review yet, a parallel run (Sonnet + Opus on the same PR)
may be in flight: re-fetch once, skip what it just posted, but do not abort — both runs may publish.

If a previous Claude finding was clearly wrong, do not argue inline; correct it in one line of the top-level body
(`"Previous finding at File.swift:42 was incorrect — <reason>. N new findings — see inline comments."`), and only
for serious false positives.

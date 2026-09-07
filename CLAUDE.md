# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Read `README.md` first — it covers what the package is, required Info.plist keys, usage, and links to the
CrowdConnected and ExpoFP SDK docs. This file only adds what the README doesn't say.

## Build

`swift build` does **not** work: the CrowdConnected and ExpoFP dependencies ship iOS-only binaries, so a macOS build
fails with `no such module 'CrowdConnectedCore'`. Build for iOS instead:

```sh
xcodebuild -scheme ExpoFpCrowdConnected -destination 'generic/platform=iOS' build
```

Library only — no app target, no tests, no linter. All source is in `ExpoFpCrowdConnected/` (3 files, ~350 lines).

## Architecture notes

`ExpoFpCrowdConnectedLocationProvider` bridges CrowdConnected to ExpoFP's `IExpoFpLocationProvider`, acting as both
`CrowdConnectedDelegate` (position/floor) and `CLLocationManagerDelegate` (heading, authorization). Non-obvious parts:

- **Two coordinate systems.** `didUpdateLocation` maps `location.type == "IPS"` to pixel `x`/`y` (floor-plan space) and
  everything else to lat/lng; both keep the current `angle`, since heading arrives via CoreLocation separately.
- **Start timeout.** `startUpdatingLocation()` arms a 65s task; if `didStartSuccess` never fires it reports an error and
  stop/start-cycles itself.
- **Settings validation.** `ExpoFpCrowdConnectedLocationProviderSettings.init` (typed `throws(ExpoFpError)`) checks the
  host app's Info.plist keys for the chosen `modules`/`trackingMode`, turning a silent runtime failure into a
  construction-time error.
- `isLocationUpdating` derives from `CrowdConnected.shared.isRunning` (a singleton — one provider per process).
- Aliases are applied only after `didStartSuccess`, since there is no device ID before that.

## Releasing

Edit `VERSION` in `publish.sh`, run it from `main`: it rewrites the README's SPM version, commits `Release v<VERSION>`,
tags, and pushes. It does **not** touch `ExpoFpCrowdConnected.podspec` — CocoaPods is frozen at 5.1.5 / CrowdConnected
2.3.0 while SPM tracks 3.x, so dependency bumps are separate edits in `Package.swift` and the podspec.

Commit messages carry the Jira key (`EFP-####`) when a change maps to a ticket.

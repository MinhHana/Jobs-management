Use Fable for planning and coordination. For anything you can scope into a clean subtask, start a Composer 2.5 subagent.

Give each subagent a clear goal, the relevant context, and what to bring back. Don't have them invent the plan. Run independent pieces in parallel.

When they return, review the results before you merge anything. If something's off, rewrite the brief and spin another, don't silently patch over it yourself unless it's trivial.

## Cursor Cloud specific instructions

This repository is a **native iOS app** (SwiftUI + SwiftData + CloudKit, `@main App`, Xcode project at `JobsManagement/JobsManagement.xcodeproj`). It can **only** be built, run, and tested with **Xcode on macOS** targeting an iOS 17+ Simulator or device (see `README.md`).

The Cursor Cloud Agent VM is **Linux x86_64 (Ubuntu)**. Building/running/testing this app is **not possible** on this VM, and this is a hard platform limitation, not a fixable setup issue:

- There is no `xcodebuild`/`xcrun` on Linux; the `.xcodeproj` and iOS Simulator are macOS-only.
- Every source file imports Apple-proprietary frameworks unavailable on Linux: `SwiftUI`, `SwiftData` (all `Models/`), `CloudKit`, `UIKit`, `Charts`, `UserNotifications`.
- The test target (`JobsManagementTests`) uses `@testable import JobsManagement`, which pulls in `SwiftData`, so even `ProgressCalculator` logic tests cannot compile on Linux without a contrived, non-representative harness.
- Do not add a Linux Swift toolchain or a parallel SwiftPM/`Package.swift` build as a workaround — it would not represent the real app and cannot exercise the SwiftUI/SwiftData/CloudKit code paths.

To actually build/run/test: open `JobsManagement/JobsManagement.xcodeproj` in Xcode 15+ on macOS, pick an iPhone simulator, and Run (⌘R); run tests with ⌘U. iCloud/CloudKit sync additionally needs an Apple Developer account with the `iCloud.com.jobsmanagement.app` container (see `docs/icloud-sync.md`). Future Cloud (Linux) agents should treat build/run/test as environment-blocked and request a macOS runner.
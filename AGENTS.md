# iOS Development Rule

## Stack and architecture
- Use SwiftUI for all UI implementation.
- Use MVVM with feature-oriented modules in existing project structure.
- Use Observation (`@Observable`) for ViewModels and state flow.
- Use async/await for asynchronous work; avoid callback-based APIs in new code.
- Default deployment target is iOS 26 (iPhone, iPad, Mac via Mac Catalyst) unless user requests otherwise.

## Implementation boundaries
- Do not create or modify project folder structure unless user explicitly asks.
- Do not change any code in the project unless user explicitly asks for code changes.
- Before changing any code in the project, first ask: "вношу изменения?".
- Apply code changes only after the user replies "да".
- When code changes are requested, keep existing architecture and naming conventions.

## Editor feature guidance
- Keep scene data as a single source of truth (background, frame, screenshot placement).
- Treat device frames as data/assets, not hardcoded UI logic.
- Keep rendering/export logic separate from SwiftUI View layout.

## Testing
- Run MockuperCore tests from the package dir (xcassets compile only via xcodebuild, not `swift test`):
  `cd MockuperCore && xcodebuild test -scheme MockuperCore -destination 'platform=iOS Simulator,name=iPhone 17'`

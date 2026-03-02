# Copilot Instructions for TableTool

## Project Overview

TableTool is a macOS CSV editor written in Objective-C. It automatically detects CSV format specifications (delimiter, encoding, decimal separator, quoting style) and provides a grid-based UI for editing CSV files.

## Repository Structure

- **`Table Tool/`** – Main application source (Objective-C `.h`/`.m` files)
  - `CSVReader.h/.m` – Reads and parses CSV data
  - `CSVWriter.h/.m` – Writes CSV data
  - `CSVHeuristic.h/.m` – Auto-detects CSV format from file content
  - `CSVConfiguration.h/.m` – Data model for CSV format settings (delimiter, encoding, quote character, etc.)
  - `Document.h/.m` – NSDocument subclass managing the open file
  - `TTFormatViewController.h/.m` – UI for selecting/overriding CSV format
  - `TTPreferencesWindowController.h/.m` – Preferences window
- **`Table ToolTests/`** – XCTest unit tests (Objective-C)
- **`Table Tool.xcodeproj`** – Xcode project file

## Build & Test Commands

Build the project:
```bash
xcodebuild build \
  -project "Table Tool.xcodeproj" \
  -scheme "Table Tool" \
  -destination "platform=macOS" \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO CODE_SIGNING_ALLOWED=NO
```

Run all tests:
```bash
xcodebuild test \
  -project "Table Tool.xcodeproj" \
  -scheme "Table Tool" \
  -destination "platform=macOS" \
  -configuration Debug \
  ONLY_ACTIVE_ARCH=NO \
  MACOSX_DEPLOYMENT_TARGET=10.13 \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGNING_ALLOWED=NO \
  ENABLE_TESTABILITY=YES
```

## Coding Conventions

- **Language**: Objective-C for all source files. The project has a Swift bridging header (`Table Tool-Bridging-Header.h`) but no Swift source files yet.
- **Naming**: Follow Apple/Cocoa conventions — `camelCase` for methods and variables, `PascalCase` for classes and types. Prefix custom classes with `TT` (e.g., `TTFormatViewController`) or `CSV` (e.g., `CSVReader`).
- **Memory management**: Use ARC (Automatic Reference Counting).
- **Error handling**: Pass `NSError **` out-parameters for recoverable errors (see `CSVReader -readLineWithError:`).
- **Tests**: Add XCTest test methods in `Table ToolTests/Table_ToolTests.m`. Use `XCTAssert*` macros. Add any required test CSV files under `Table ToolTests/Reading Test Documents/` or `Table ToolTests/Heuristic Test Documents/`.

## Key Notes

- The macOS deployment target in the Xcode project is **10.8**. CI builds override it to **10.13** via the `MACOSX_DEPLOYMENT_TARGET` build flag.
- Do not add third-party dependencies unless absolutely necessary; the project has no external package manager (no CocoaPods, Carthage, or SPM).
- All UI is AppKit-based (no SwiftUI).
- CI runs on `macos-14` via GitHub Actions (see `.github/workflows/ci.yml`).

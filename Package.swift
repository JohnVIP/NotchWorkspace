// swift-tools-version: 6.2
// SPDX-License-Identifier: MIT
import PackageDescription

// Swift 6 enables strict concurrency checking. Treat warnings as errors.
let strict: [SwiftSetting] = [.treatAllWarnings(as: .error)]

let package = Package(
    name: "OpenNotchKit",
    platforms: [.macOS("14.6")],
    products: [
        .library(name: "NotchCore", targets: ["NotchCore"]),
        .library(name: "NotchSurface", targets: ["NotchSurface"]),
        .library(name: "NotchFeatures", targets: ["NotchFeatures"]),
        .library(name: "NotchAgents", targets: ["NotchAgents"]),
    ],
    targets: [
        // State machine, feature lifecycle, diagnostics. No AppKit, so it tests anywhere.
        .target(name: "NotchCore", swiftSettings: strict),
        // Panel, SwiftUI surface, and notch geometry.
        .target(
            name: "NotchSurface", dependencies: ["NotchCore"],
            // The notch's own icons from Tabler Icons (tabler.io; MIT, see THIRD_PARTY_NOTICES.md).
            resources: [.copy("Resources/Icons")], swiftSettings: strict),
        // Feature modules: each one a NotchFeature plus its views.
        .target(name: "NotchFeatures", dependencies: ["NotchCore"], swiftSettings: strict),
        // Claude Code and Codex session status in the GitHub build.
        .target(name: "NotchAgents", dependencies: ["NotchCore", "NotchFeatures"], swiftSettings: strict),
        .testTarget(name: "NotchCoreTests", dependencies: ["NotchCore"], swiftSettings: strict),
        .testTarget(name: "NotchSurfaceTests", dependencies: ["NotchSurface"], swiftSettings: strict),
        .testTarget(name: "NotchFeaturesTests", dependencies: ["NotchFeatures"], swiftSettings: strict),
        .testTarget(name: "NotchAgentsTests", dependencies: ["NotchAgents"], swiftSettings: strict),
        // XCTest metrics (clock, CPU, memory, signposts) for the core's hot paths.
        .testTarget(name: "PerformanceTests", dependencies: ["NotchCore"], swiftSettings: strict),
    ]
)

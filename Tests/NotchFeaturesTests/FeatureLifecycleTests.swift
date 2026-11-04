// SPDX-License-Identifier: MIT
import Foundation
import NotchCore
import Testing

@testable import NotchFeatures

/// The Phase 4 exit: every module starts, suspends, resumes, and releases its resources correctly,
/// driven the way the app drives it, through the FeatureHost.
@MainActor
struct FeatureLifecycleTests {
    private let folder = FileManager.default.temporaryDirectory.appending(path: "Lifecycle-\(UUID().uuidString)")
    private let defaults = UserDefaults(suiteName: "Lifecycle.\(UUID().uuidString)")!

    @Test func everyFeatureFollowsTheNotchThroughASessionAndReleasesEverything() throws {
        try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
        let eventStore = EventStore()
        let shelf = ShelfFeature(storeURL: folder.appending(path: "shelf.json"))
        let calendar = CalendarFeature(eventStore: eventStore, defaults: defaults)
        let tasks = TasksFeature(eventStore: eventStore, defaults: defaults)
        let notes = NotesFeature(directory: folder.appending(path: "Notes"))
        let shortcuts = ShortcutsFeature(defaults: defaults)
        let timer = TimerFeature()
        let features: [any NotchFeature] = [shelf, calendar, tasks, notes, shortcuts, timer]
        let host = FeatureHost(features)
        let enabled = Set(FeatureID.allCases)
        let drop = Activity(feature: .shelf, symbol: "tray.full", title: "2 files", duration: .seconds(1))

        // A session: shown, every tab opened in turn, a live activity, sleep, wake, then quit.
        var session: [NotchPresentationState] = [.compact]
        session += FeatureID.allCases.map { .expanded(tab: $0) }
        session += [.transient(drop), .suspended, .compact]
        for presentation in session {
            host.update(presentations: [presentation], enabled: enabled)
            for feature in features {
                #expect(feature.phase == presentation.phase(for: feature.id), "\(feature.id) at \(presentation)")
            }
            if presentation == .expanded(tab: .notes) { notes.update(notes.add(), text: "written during the session") }
        }

        host.update(presentations: [], enabled: enabled)  // quit

        #expect(features.allSatisfy { $0.phase == .stopped })
        #expect(!calendar.isObserving && calendar.events.isEmpty)
        #expect(!tasks.isObserving && tasks.tasks.isEmpty)
        #expect(notes.notes.isEmpty, "notes leave memory")
        #expect(
            try FileManager.default.contentsOfDirectory(atPath: folder.appending(path: "Notes").path).count == 1,
            "and what was typed is on disk")
        #expect(shortcuts.shortcuts.isEmpty)
    }
}

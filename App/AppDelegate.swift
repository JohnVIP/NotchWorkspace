// SPDX-License-Identifier: MIT
import AppKit
import NotchAgents
import NotchCore
import NotchFeatures
import NotchSurface
import SwiftUI

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private let preferences = NotchPreferences()
    private let agents = AgentsFeature()
    private let shelf = ShelfFeature()
    private let calendar: CalendarFeature
    private let tasks: TasksFeature
    private let notes = NotesFeature()
    private let shortcuts = ShortcutsFeature()
    private let timer = TimerFeature()
    private lazy var features = FeatureHost(featureList)
    // System live activities, which belong to no tab.
    private let volume = VolumeMonitor()
    private let battery = BatteryMonitor()
    private let accessories = AccessoryMonitor()
    /// Opens and closes the notch from any app.
    private let notchKey = HotKey()
    /// Escape, only while a notch the shortcut opened is still open.
    private let escapeKey = HotKey()
    /// Starts a new note from any app, while Notes has it on.
    private let quickNoteKey = HotKey()

    override init() {
        let eventStore = EventStore()  // shared, and only created when Calendar or Tasks first needs it
        calendar = CalendarFeature(eventStore: eventStore)
        tasks = TasksFeature(eventStore: eventStore)
        super.init()
    }
    private var coordinator: PanelCoordinator?
    /// Show in Notch messages that arrived while launching, before there was a notch to show them.
    private var pendingMessages: [Activity] = []
    private var statusItem: StatusItemController?
    private lazy var settings = SettingsWindowController(
        preferences: preferences,
        notchKey: notchKey,
        previewAnimation: { [weak self] in self?.coordinator?.previewAnimation() },
        featureSettings: { [unowned self] in self.settingsView(for: $0) })

    private var featureList: [any NotchFeature] {
        [shelf, calendar, tasks, notes, shortcuts, timer, agents]
    }

    private func tabView(for feature: FeatureID) -> AnyView {
        switch feature {
        case .shelf: return AnyView(shelf.view)
        case .calendar: return AnyView(calendar.view)
        case .tasks: return AnyView(tasks.view)
        case .notes: return AnyView(notes.view)
        case .shortcuts: return AnyView(shortcuts.view)
        case .timer: return AnyView(timer.view)
        case .agents:
            return AnyView(agents.view)
        }
    }

    /// Each tab's own settings, as the sections of its Settings page.
    private func settingsView(for feature: FeatureID) -> AnyView? {
        switch feature {
        case .shelf: return section(shelf.settingsView)
        case .calendar: return section(calendar.settingsView)
        case .tasks: return section(tasks.settingsView)
        case .shortcuts: return section(shortcuts.settingsView)
        case .notes: return section(notes.settingsView)
        case .timer: return nil
        case .agents:
            return section(agents.settingsView)
        }
    }

    private func section(_ rows: some View) -> AnyView { AnyView(Section { rows }) }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let content = NotchContent(
            tab: { [unowned self] in self.tabView(for: $0) },
            dropFiles: { [preferences, shelf] urls in preferences.isEnabled(.shelf) && shelf.add(urls) },
            openSettings: { [weak self] in self?.settings.show() })
        let coordinator = PanelCoordinator(preferences: preferences, content: content)
        coordinator.onPresentationsChange = { [weak self] presentations in
            guard let self else { return }
            features.update(presentations: presentations, enabled: Set(preferences.tabs))
            if !presentations.contains(where: { $0.openTab != nil }) { escapeKey.shortcut = nil }
        }
        notchKey.onPress = { [weak self, weak coordinator] in
            guard let self, coordinator?.toggleNotch() == true else { return }
            escapeKey.shortcut = .escape
        }
        escapeKey.onPress = { [weak coordinator] in coordinator?.dismissAll() }
        shelf.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        calendar.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        calendar.onOngoing = { [weak coordinator] in coordinator?.setOngoing($0, for: .calendar) }
        timer.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        timer.onOngoing = { [weak coordinator] in coordinator?.setOngoing($0, for: .timer) }
        shortcuts.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        tasks.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        notes.onSendToTasks = { [tasks] in tasks.add($0) }
        quickNoteKey.onPress = { [weak self] in self?.startQuickNote() }
        volume.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        battery.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        accessories.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        agents.onActivity = { [weak coordinator] in coordinator?.broadcast(.activity($0)) }
        agents.onOngoing = { [weak coordinator] in coordinator?.setOngoing($0, for: .agents) }
        coordinator.start()
        self.coordinator = coordinator
        pendingMessages.forEach(showInNotch)
        pendingMessages = []
        observeContinuously { [weak self] in self?.updateSystemActivities() }
        observeContinuously { [weak self] in
            guard let self else { return }
            notchKey.shortcut = preferences.notchShortcut
        }
        statusItem = StatusItemController { [weak self] in self?.settings.show($0) }
    }

    /// Show in Notch links from scripts and other apps: notchworkspace://show?title=….
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            guard let message = ShowInNotch.activity(from: url) else {
                Log.features.info("Ignored a link: \(url.absoluteString, privacy: .private)")
                continue
            }
            showInNotch(message)
        }
    }

    /// Shows a message from outside ILoveNotch, from a link or the Shortcuts action, as a live
    /// activity.
    func showInNotch(_ message: Activity) {
        guard let coordinator else {
            pendingMessages.append(message)
            return
        }
        coordinator.broadcast(.activity(message))
    }

    func applicationWillTerminate(_ notification: Notification) {
        // Stops all feature work.
        features.update(presentations: [], enabled: [])
        timer.allowSleep()
        volume.stop()
        battery.stop()
        accessories.stop()
    }

    /// Opens the notch on Notes with a new note, ready to type. The tab gets a moment to come on
    /// screen and load before the note is added and the editor takes the keyboard.
    private func startQuickNote() {
        guard let coordinator, preferences.isEnabled(.notes) else { return }
        coordinator.open(.notes)
        Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(150))
            guard let self else { return }
            notes.quickCapture()
            self.coordinator?.focusKeyboard()
        }
    }

    /// Runs each system activity's listener, and the quick note shortcut, only while Settings has it
    /// on.
    private func updateSystemActivities() {
        // Keep awake lives in the Timer tab: turning the tab off must not leave the Mac awake unseen.
        if !preferences.isEnabled(.timer) { timer.allowSleep() }
        preferences.showsVolume ? volume.start() : volume.stop()
        preferences.showsBattery ? battery.start() : battery.stop()
        preferences.showsAccessoryBattery ? accessories.start() : accessories.stop()
        quickNoteKey.shortcut = notes.quickNoteShortcut && preferences.isEnabled(.notes) ? .newNote : nil
    }
}

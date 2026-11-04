// SPDX-License-Identifier: MIT
import AppKit

/// The menu bar fallback: always reachable, even when the notch is hidden or misbehaving. The menu
/// shows the running build and opens Settings.
@MainActor
final class StatusItemController: NSObject, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let openSettings: (SettingsSelection.Page?) -> Void

    init(openSettings: @escaping (SettingsSelection.Page?) -> Void) {
        self.openSettings = openSettings
        super.init()
        statusItem.button?.image = NSImage(
            systemSymbolName: "rectangle.topthird.inset.filled", accessibilityDescription: "Notch Workspace")
        let menu = NSMenu()
        menu.delegate = self
        statusItem.menu = menu
    }

    func menuNeedsUpdate(_ menu: NSMenu) {
        menu.removeAllItems()
        menu.addItem(.sectionHeader(title: "Notch Workspace \(AppVersion.display)"))
        menu.addItem(menuItem("Settings…", symbol: "gearshape", #selector(showSettings), key: ","))
        menu.addItem(.separator())
        menu.addItem(menuItem("About Notch Workspace", symbol: "info.circle", #selector(showAbout)))
        menu.addItem(menuItem("Sponsor ILoveNotch…", symbol: "heart", #selector(sponsor)))
        menu.addItem(.separator())
        let quit = NSMenuItem(
            title: "Quit Notch Workspace", action: #selector(NSApplication.terminate), keyEquivalent: "q")
        quit.image = NSImage(systemSymbolName: "power", accessibilityDescription: nil)
        menu.addItem(quit)
    }

    private func menuItem(_ title: String, symbol: String, _ action: Selector?, key: String = "") -> NSMenuItem {
        let item = NSMenuItem(title: title, action: action, keyEquivalent: key)
        item.target = self
        item.image = NSImage(systemSymbolName: symbol, accessibilityDescription: nil)
        return item
    }

    @objc private func showSettings() { openSettings(nil) }
    @objc private func showAbout() { openSettings(.about) }
    @objc private func sponsor() { NSWorkspace.shared.open(Links.sponsor) }
}

enum Links {
    static let repository = URL(string: "https://github.com/JohnVIP/NotchWorkspace")!
    static let sponsor = URL(string: "https://github.com/sponsors/niyamvora")!
    static let contributing = URL(string: "https://github.com/JohnVIP/NotchWorkspace/blob/main/CONTRIBUTING.md")!
    static let newIssue = URL(string: "https://github.com/JohnVIP/NotchWorkspace/issues/new/choose")!
    static let privacy = URL(string: "https://github.com/JohnVIP/NotchWorkspace/blob/main/PRIVACY.md")!
    /// The built app also carries a copy in its Resources.
    static let acknowledgements = URL(
        string: "https://github.com/JohnVIP/NotchWorkspace/blob/main/THIRD_PARTY_NOTICES.md")!
}

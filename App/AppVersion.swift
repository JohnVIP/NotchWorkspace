// SPDX-License-Identifier: MIT
import Foundation

enum AppVersion {
    static var display: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?"
        guard let commit = Bundle.main.object(forInfoDictionaryKey: "NotchWorkspaceCommit") as? String,
            !commit.isEmpty
        else { return version }
        return "\(version) (\(commit))"
    }
}

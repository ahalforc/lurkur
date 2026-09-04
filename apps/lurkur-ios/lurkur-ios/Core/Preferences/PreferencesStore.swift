import Foundation
import Observation
import SwiftUI

enum ThemeBrightness: String, CaseIterable, Identifiable {
    case light
    case dark
    case system

    var id: String { rawValue }

    var colorScheme: ColorScheme? {
        switch self {
        case .light: .light
        case .dark: .dark
        case .system: nil
        }
    }

    var label: String {
        switch self {
        case .light: "Light"
        case .dark: "Dark"
        case .system: "System"
        }
    }
}

@MainActor
@Observable
final class PreferencesStore {
    private enum Keys {
        static let brightness = "theme brightness"
        static let hideAutoModerator = "hide auto moderator comments"
        static let hiddenSubreddits = "hidden subreddits"
    }

    private(set) var brightness: ThemeBrightness = .system
    private(set) var hideAutoModeratorComments = false
    private(set) var hiddenSubreddits: Set<String> = []
    /// Bumped on clear-all so feeds discard kept sessions and reload.
    private(set) var feedSessionEpoch: Int = 0

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        reload()
    }

    func reload() {
        if let raw = defaults.string(forKey: Keys.brightness),
           let value = ThemeBrightness(rawValue: raw)
        {
            brightness = value
        } else {
            brightness = .system
        }
        hideAutoModeratorComments = defaults.bool(forKey: Keys.hideAutoModerator)
        hiddenSubreddits = Set(defaults.stringArray(forKey: Keys.hiddenSubreddits) ?? [])
    }

    func setBrightness(_ value: ThemeBrightness) {
        brightness = value
        defaults.set(value.rawValue, forKey: Keys.brightness)
    }

    func setHideAutoModeratorComments(_ value: Bool) {
        hideAutoModeratorComments = value
        defaults.set(value, forKey: Keys.hideAutoModerator)
    }

    func hideSubreddit(_ name: String) {
        hiddenSubreddits.insert(name)
        persistHidden()
    }

    func showSubreddit(_ name: String) {
        hiddenSubreddits.remove(name)
        persistHidden()
    }

    func clearAll() {
        defaults.removeObject(forKey: Keys.brightness)
        defaults.removeObject(forKey: Keys.hideAutoModerator)
        defaults.removeObject(forKey: Keys.hiddenSubreddits)
        reload()
        feedSessionEpoch += 1
    }

    func isHidden(_ subreddit: String) -> Bool {
        hiddenSubreddits.contains(subreddit)
    }

    private func persistHidden() {
        defaults.set(Array(hiddenSubreddits).sorted(), forKey: Keys.hiddenSubreddits)
    }
}

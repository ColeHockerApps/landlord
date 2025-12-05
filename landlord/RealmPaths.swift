import Foundation
import Combine

final class RealmPaths: ObservableObject {
    @Published var entryPoint: URL
    @Published var tomeScroll: URL

    private let entryKey = "realm.entry.link"
    private let scrollKey = "realm.scroll.link"
    private let trailKey  = "realm.trail.mark"
    private let marksKey  = "realm.trail.marks"

    private var hasStoredTrail = false

    init() {
        let defaults = UserDefaults.standard

        let defaultEntry  = "https://malikdanar.github.io/landlord"
        let defaultScroll = "https://malikdanar.github.io/landlord-privacys"

        if let saved = defaults.string(forKey: entryKey),
           let url = URL(string: saved) {
            entryPoint = url
        } else {
            entryPoint = URL(string: defaultEntry)!
        }

        if let saved = defaults.string(forKey: scrollKey),
           let url = URL(string: saved) {
            tomeScroll = url
        } else {
            tomeScroll = URL(string: defaultScroll)!
        }
    }

    func updateEntry(_ link: String) {
        guard let url = URL(string: link) else { return }
        entryPoint = url
        UserDefaults.standard.set(link, forKey: entryKey)
    }

    func updateScroll(_ link: String) {
        guard let url = URL(string: link) else { return }
        tomeScroll = url
        UserDefaults.standard.set(link, forKey: scrollKey)
    }

    func storeTrailIfNeeded(_ link: URL) {
        guard hasStoredTrail == false else { return }
        hasStoredTrail = true

        let defaults = UserDefaults.standard
        if defaults.string(forKey: trailKey) != nil {
            return
        }

        defaults.set(link.absoluteString, forKey: trailKey)
    }

    func restoreStoredTrail() -> URL? {
        let defaults = UserDefaults.standard
        if let saved = defaults.string(forKey: trailKey),
           let url = URL(string: saved) {
            return url
        }
        return nil
    }

    func saveMarks(_ items: [[String: Any]]) {
        UserDefaults.standard.set(items, forKey: marksKey)
    }

    func currentMarks() -> [[String: Any]]? {
        UserDefaults.standard.array(forKey: marksKey) as? [[String: Any]]
    }
}

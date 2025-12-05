import Foundation
import Combine

struct MatchProgress: Codable {
    var highestLevel: Int
    var totalStars: Int
    var totalScore: Int
    var lastPlayedDate: Date
}

final class MatchProgressStore: ObservableObject {
    @Published private(set) var progress: MatchProgress

    private let storageKey = "landlord.match.progress"
    private let queue = DispatchQueue(label: "landlord.match.progress.queue", qos: .background)

    init() {
        if let saved = Self.loadFromDefaults(key: storageKey) {
            progress = saved
        } else {
            progress = MatchProgress(
                highestLevel: 1,
                totalStars: 0,
                totalScore: 0,
                lastPlayedDate: Date()
            )
        }
    }

    func registerLevelCompletion(level: Int, stars: Int, score: Int) {
        let clampedStars = max(0, min(stars, 3))
        let clampedScore = max(0, score)

        if level > progress.highestLevel {
            progress.highestLevel = level
        }

        progress.totalStars += clampedStars
        progress.totalScore += clampedScore
        progress.lastPlayedDate = Date()

        save()
    }

    func resetProgress() {
        progress = MatchProgress(
            highestLevel: 1,
            totalStars: 0,
            totalScore: 0,
            lastPlayedDate: Date()
        )
        save()
    }

    private func save() {
        let current = progress
        queue.async { [storageKey] in
            Self.saveToDefaults(current, key: storageKey)
        }
    }

    private static func loadFromDefaults(key: String) -> MatchProgress? {
        let defaults = UserDefaults.standard
        guard let data = defaults.data(forKey: key) else {
            return nil
        }
        return try? JSONDecoder().decode(MatchProgress.self, from: data)
    }

    private static func saveToDefaults(_ progress: MatchProgress, key: String) {
        let defaults = UserDefaults.standard
        guard let data = try? JSONEncoder().encode(progress) else {
            return
        }
        defaults.set(data, forKey: key)
    }
}

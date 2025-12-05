import Foundation
import Combine

struct MatchScoreBreakdown: Identifiable {
    let id = UUID()
    let basePoints: Int
    let comboMultiplier: Int
    let chainMultiplier: Int
    let totalPoints: Int
    let tilesCleared: Int
}

final class MatchScoreSystem: ObservableObject {
    @Published private(set) var totalScore: Int = 0
    @Published private(set) var moveCount: Int = 0
    @Published private(set) var lastBreakdown: MatchScoreBreakdown?
    @Published private(set) var bestComboMultiplier: Int = 1
    @Published private(set) var bestChainMultiplier: Int = 1

    private let basePointsPerTile: Int
    private let movePenalty: Int
    private let maxPenaltyPerMove: Int

    init(basePointsPerTile: Int = 10, movePenalty: Int = 2, maxPenaltyPerMove: Int = 20) {
        self.basePointsPerTile = basePointsPerTile
        self.movePenalty = movePenalty
        self.maxPenaltyPerMove = maxPenaltyPerMove
    }

    func registerMove() {
        moveCount += 1
    }

    func registerMatch(tilesCleared: Int, comboIndex: Int, chainIndex: Int) -> MatchScoreBreakdown {
        let comboMultiplier = max(1, comboIndex)
        let chainMultiplier = max(1, chainIndex)

        let basePoints = tilesCleared * basePointsPerTile
        let total = basePoints * comboMultiplier * chainMultiplier

        totalScore += total

        if comboMultiplier > bestComboMultiplier {
            bestComboMultiplier = comboMultiplier
        }

        if chainMultiplier > bestChainMultiplier {
            bestChainMultiplier = chainMultiplier
        }

        let breakdown = MatchScoreBreakdown(
            basePoints: basePoints,
            comboMultiplier: comboMultiplier,
            chainMultiplier: chainMultiplier,
            totalPoints: total,
            tilesCleared: tilesCleared
        )

        lastBreakdown = breakdown
        return breakdown
    }

    func applyMovePenalty(forEmptyMove: Bool) {
        guard forEmptyMove else { return }
        let penalty = min(movePenalty * max(1, moveCount / 5), maxPenaltyPerMove)
        totalScore = max(0, totalScore - penalty)
    }

    func reset() {
        totalScore = 0
        moveCount = 0
        lastBreakdown = nil
        bestComboMultiplier = 1
        bestChainMultiplier = 1
    }
}

import Foundation
import Combine

final class MatchEngine: ObservableObject {
    @Published private(set) var board: MatchBoardState
    @Published private(set) var score: Int = 0

    private let levelConfig: MatchLevelConfig

    init(levelConfig: MatchLevelConfig) {
        self.levelConfig = levelConfig
        self.board = MatchBoardState(rows: levelConfig.rows, cols: levelConfig.cols)
    }

    func performMove(from: MatchPosition, to: MatchPosition) -> Bool {
        guard areNeighbors(from, to) else {
            return false
        }

        board.swap(from, to)

        let initialMatches = findAllMatches()
        if initialMatches.isEmpty {
            board.swap(from, to)
            return false
        }

        let gained = resolveMatches()
        score += gained
        return true
    }

    @discardableResult
    func resolveMatches() -> Int {
        var totalScore = 0

        while true {
            let matches = findAllMatches()
            if matches.isEmpty {
                break
            }

            totalScore += matches.count * 10
            board.clearMatches(matches)
            board.collapseColumns()
            board.fillEmptyTiles()
        }

        return totalScore
    }

    private func areNeighbors(_ a: MatchPosition, _ b: MatchPosition) -> Bool {
        let dr = abs(a.row - b.row)
        let dc = abs(a.col - b.col)
        return (dr == 1 && dc == 0) || (dr == 0 && dc == 1)
    }

    private func findAllMatches() -> Set<MatchPosition> {
        var result = Set<MatchPosition>()
        result.formUnion(findHorizontalMatches())
        result.formUnion(findVerticalMatches())
        return result
    }

    private func findHorizontalMatches() -> Set<MatchPosition> {
        var positions = Set<MatchPosition>()

        for row in 0..<board.rows {
            var currentRun: [MatchPosition] = []
            var lastType: MatchTileType?

            for col in 0..<board.cols {
                let pos = MatchPosition(row: row, col: col)
                if let tile = board.tile(at: pos) {
                    if let last = lastType, last == tile.type {
                        currentRun.append(pos)
                    } else {
                        if currentRun.count >= 3 {
                            positions.formUnion(currentRun)
                        }
                        currentRun = [pos]
                        lastType = tile.type
                    }
                } else {
                    if currentRun.count >= 3 {
                        positions.formUnion(currentRun)
                    }
                    currentRun.removeAll()
                    lastType = nil
                }
            }

            if currentRun.count >= 3 {
                positions.formUnion(currentRun)
            }
        }

        return positions
    }

    private func findVerticalMatches() -> Set<MatchPosition> {
        var positions = Set<MatchPosition>()

        for col in 0..<board.cols {
            var currentRun: [MatchPosition] = []
            var lastType: MatchTileType?

            for row in 0..<board.rows {
                let pos = MatchPosition(row: row, col: col)
                if let tile = board.tile(at: pos) {
                    if let last = lastType, last == tile.type {
                        currentRun.append(pos)
                    } else {
                        if currentRun.count >= 3 {
                            positions.formUnion(currentRun)
                        }
                        currentRun = [pos]
                        lastType = tile.type
                    }
                } else {
                    if currentRun.count >= 3 {
                        positions.formUnion(currentRun)
                    }
                    currentRun.removeAll()
                    lastType = nil
                }
            }

            if currentRun.count >= 3 {
                positions.formUnion(currentRun)
            }
        }

        return positions
    }
}

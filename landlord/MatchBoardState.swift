import Foundation
import Combine

final class MatchBoardState: ObservableObject {
    @Published private(set) var rows: Int
    @Published private(set) var cols: Int
    @Published private(set) var tiles: [[MatchTile?]]

    init(rows: Int = 6, cols: Int = 6) {
        self.rows = rows
        self.cols = cols
        self.tiles = Array(
            repeating: Array(repeating: nil, count: cols),
            count: rows
        )
        generateInitialBoard()
    }

    private func generateInitialBoard() {
        for r in 0..<rows {
            for c in 0..<cols {
                let type = MatchTileType.allCases.randomElement() ?? .apple
                tiles[r][c] = MatchTile(type: type)
            }
        }
    }

    func tile(at position: MatchPosition) -> MatchTile? {
        guard position.row >= 0,
              position.col >= 0,
              position.row < rows,
              position.col < cols else {
            return nil
        }
        return tiles[position.row][position.col]
    }

    func setTile(_ tile: MatchTile?, at position: MatchPosition) {
        guard position.row >= 0,
              position.col >= 0,
              position.row < rows,
              position.col < cols else {
            return
        }
        tiles[position.row][position.col] = tile
    }

    func swap(_ a: MatchPosition, _ b: MatchPosition) {
        guard let tileA = tile(at: a),
              let tileB = tile(at: b) else {
            return
        }
        tiles[a.row][a.col] = tileB
        tiles[b.row][b.col] = tileA
    }

    func clearMatches(_ positions: Set<MatchPosition>) {
        for pos in positions {
            setTile(nil, at: pos)
        }
    }

    func collapseColumns() {
        for col in 0..<cols {
            var column: [MatchTile?] = []
            for row in 0..<rows {
                column.append(tiles[row][col])
            }

            let filtered = column.compactMap { $0 }
            let missing = rows - filtered.count
            let newTiles: [MatchTile?] = Array(repeating: nil, count: missing) + filtered

            for row in 0..<rows {
                tiles[row][col] = newTiles[row]
            }
        }
    }

    func fillEmptyTiles() {
        for r in 0..<rows {
            for c in 0..<cols {
                if tiles[r][c] == nil {
                    let type = MatchTileType.allCases.randomElement() ?? .apple
                    tiles[r][c] = MatchTile(type: type)
                }
            }
        }
    }
}

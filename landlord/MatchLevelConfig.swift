import Foundation
import Combine

struct MatchLevelConfig {
    let level: Int
    let rows: Int
    let cols: Int
    let targetScore: Int

    init(level: Int) {
        self.level = level

        if level < 10 {
            self.rows = 6
            self.cols = 6
            self.targetScore = 300
        } else if level < 20 {
            self.rows = 7
            self.cols = 6
            self.targetScore = 600
        } else if level < 30 {
            self.rows = 7
            self.cols = 7
            self.targetScore = 900
        } else {
            self.rows = 8
            self.cols = 7
            self.targetScore = 1200
        }
    }
}

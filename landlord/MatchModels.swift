import Foundation
import SwiftUI
import Combine

enum MatchTileType: CaseIterable {
    case apple
    case mushroom
    case carrot
    case strawberry

    var assetName: String {
        switch self {
        case .apple: return LandlordAssets.Images.apple
        case .mushroom: return LandlordAssets.Images.mushroom
        case .carrot: return LandlordAssets.Images.carrot
        case .strawberry: return LandlordAssets.Images.strawberry
        }
    }

    var displayColor: Color {
        switch self {
        case .apple: return Color.red
        case .mushroom: return Color.brown
        case .carrot: return Color.orange
        case .strawberry: return Color(red: 0.95, green: 0.1, blue: 0.3)
        }
    }
}

struct MatchTile: Identifiable, Equatable {
    let id = UUID()
    let type: MatchTileType
    var isFalling: Bool = false
    var isMatched: Bool = false
}

struct MatchPosition: Hashable {
    let row: Int
    let col: Int
}

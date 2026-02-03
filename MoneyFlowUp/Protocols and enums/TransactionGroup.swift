

import Foundation
import SwiftUI

enum TransactionGroup: String, CaseIterable {
    
    case cost = "Трата"
    case income = "Заработок"
    case transfer = "Перевод"
    
    var icon: String {
        switch self {
        case .cost:
            return "cart.badge.plus"
        case .income:
            return "dollarsign.ring.dashed"
        case .transfer:
            return "arrow.triangle.2.circlepath"
        }
    }
    
    var color: Color {
        switch self {
        case .cost: return .red
        case .income: return .green
        case .transfer: return .blue
        }
    }
    
    
}

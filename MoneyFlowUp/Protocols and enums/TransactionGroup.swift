import Foundation
import SwiftUI

// Группа транзакций: Трата, Заработок, Перевод.
// Содержит локализованное имя (rawValue), иконку и цвет для UI.
enum TransactionGroup: String, CaseIterable {
    
    case cost = "Трата"
    case income = "Заработок"
    case transfer = "Перевод"
    
    // Иконка для чипов/вкладок
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
    
    // Цвет группы (используется в UI при выделении)
    var color: Color {
        switch self {
        case .cost: return .red
        case .income: return .green
        case .transfer: return .blue
        }
    }
}


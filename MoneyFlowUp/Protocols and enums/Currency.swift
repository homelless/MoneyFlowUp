

import Foundation
import SwiftUI


 enum Currency: String, CaseIterable, Identifiable, Codable {
    
        case usd = "$"
        case rub = "₽"
        case eur = "€"
    
    public var id: String { rawValue }
}

import Foundation
import SwiftUI

// Перечисление поддерживаемых валют.
// Хранит символ валюты как rawValue. Можно расширять новыми вариантами.
enum Currency: String, CaseIterable, Identifiable, Codable {
    case usd = "$"
    //  case rub = "₽"
    //  case eur = "€"
    
    public var id: String { rawValue }
}


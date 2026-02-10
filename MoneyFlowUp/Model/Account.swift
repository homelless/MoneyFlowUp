import Foundation
import SwiftData
import SwiftUI

// Модель счета/кошелька для хранения в SwiftData.
// Содержит идентификатор, имя, баланс, валюту, описание и порядок сортировки.

@Model
class Account: Identifiable, Hashable {
    var id: UUID                 // Уникальный идентификатор
    var name: String             // Название кошелька
    var balance: String          // Баланс (хранится строкой для простоты ввода/форматирования)
    var currencyRaw: String      // Сырая строка валюты (для совместимости со SwiftData)
    // Удобное вычисляемое свойство для доступа к enum Currency
    var currency: Currency {
        get { Currency(rawValue: currencyRaw) ?? .usd }
        set { currencyRaw = newValue.rawValue }
    }
    var descriptionAccount: String // Описание кошелька
    var sortOrder: Int             // Порядок сортировки в списке
    
    init(id: UUID, name: String, balance: String, currencyRaw: String, descriptionAccount: String, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currencyRaw = currencyRaw
        self.descriptionAccount = descriptionAccount
        self.sortOrder = sortOrder  
    }
    
    // Поддержка Hashable по id
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    // Равенство по id
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
}


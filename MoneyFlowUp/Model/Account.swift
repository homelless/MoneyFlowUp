import Foundation
import SwiftData
import SwiftUI

// Модель счета/кошелька для хранения в SwiftData.
// Содержит идентификатор, имя, баланс, валюту, описание и порядок сортировки.

@Model
class Account: Identifiable, Hashable {
    var id: UUID                 // Уникальный идентификатор
    var name: String             // Название кошелька
    var balance: Decimal         // Баланс (Decimal — деньги считаем без погрешности Double)
    var currencyRaw: String      // Сырая строка валюты (для совместимости со SwiftData)
    // Удобное вычисляемое свойство для доступа к enum Currency
    var currency: Currency {
        get { Currency(rawValue: currencyRaw) ?? .usd }
        set { currencyRaw = newValue.rawValue }
    }
    var descriptionAccount: String // Описание кошелька
    var sortOrder: Int             // Порядок сортировки в списке

    // Транзакции, где этот кошелёк — источник. Каскад: при удалении кошелька они удаляются автоматически.
    @Relationship(deleteRule: .cascade, inverse: \Transaction.account)
    var outgoingTransactions: [Transaction] = []
    // Транзакции-переводы, где этот кошелёк — получатель. Тоже каскадно удаляются вместе с кошельком.
    @Relationship(deleteRule: .cascade, inverse: \Transaction.toAccount)
    var incomingTransactions: [Transaction] = []

    init(id: UUID, name: String, balance: Decimal, currencyRaw: String, descriptionAccount: String, sortOrder: Int = 0) {
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


import Foundation
import SwiftData

// Модель транзакции для хранения в SwiftData.
// Содержит сумму, дату, заметку, привязку к аккаунту и категорию (сериализованную в categoryJSON).
@Model
class Transaction: Identifiable {
    // Уникальный идентификатор транзакции
    var id: UUID
    // Сумма транзакции
    var amount: Double
    // Сериализованное представление категории (для хранения в SwiftData)
    var categoryJSON: String?
    // Дата и время транзакции
    var date: Date
    // Опциональная заметка пользователя
    var note: String?
    // Идентификатор аккаунта, к которому относится транзакция
    var accountId: UUID
    
    init(id: UUID, amount: Double, category: TransactionCategory, date: Date, note: String? = nil, accountId: UUID) {
        self.id = id
        self.amount = amount
        self.categoryJSON = Self.encodeCategory(category)
        self.date = date
        self.note = note
        self.accountId = accountId
    }
    
    // Доменное свойство: категория транзакции, оборачивает categoryJSON с кодированием/декодированием
    var category: TransactionCategory {
        get {
            if let json = categoryJSON, let decoded = Self.decodeCategory(json) {
                return decoded
            }
            // Значение по умолчанию, если декодирование не удалось
            return .cost(.sort)
        }
        set {
            categoryJSON = Self.encodeCategory(newValue)
        }
    }
    
    // Удобные флаги для UI: определение типа транзакции
    var isExpense: Bool {
        if case .cost = category { return true }
        return false
    }
    
    var isIncome: Bool {
        if case .income = category { return true }
        return false
    }
    
    var isTransfer: Bool {
        if case .transfer = category { return true }
        return false
    }
    
    // Примитивное кодирование категории в строку "type:id" для хранения
    private static func encodeCategory(_ category: TransactionCategory) -> String {
        switch category {
        case .cost(let costCategory):
            return "cost:\(costCategory.id)"
        case .income(let incomeCategory):
            return "income:\(incomeCategory.id)"
        case .transfer(let transferType):
            return "transfer:\(transferType.id)"
        }
    }
    
    // Обратное преобразование строки "type:id" в TransactionCategory
    private static func decodeCategory(_ json: String) -> TransactionCategory? {
        let parts = json.split(separator: ":")
        guard parts.count == 2 else { return nil }
        
        let type = String(parts[0])
        let id = String(parts[1])
        
        switch type {
        case "cost":
            // --- НОВОЕ: расширяем поиск на все категории (включая пользовательские) ---
            let allCategories = CategoriesStores.sharedCost?.categories ?? CostCategory.all
            return allCategories.first { $0.id == id }.map { .cost($0) }
        case "income":
            let allCategories = CategoriesStores.sharedIncome?.categories ?? IncomeCategory.all
            return allCategories.first { $0.id == id }.map { .income($0) }
        case "transfer":
            return TransferType.all.first { $0.id == id }.map { .transfer($0) }
        default:
            return nil
        }
    }
}


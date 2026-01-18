
import Foundation
import SwiftData


@Model
class Transaction: Identifiable {
    var id: UUID
    var amount: Double
    var categoryJSON: String?
    var date: Date
    var note: String?
    var accountId: UUID
    
    init(id: UUID, amount: Double, category: TransactionCategory, date: Date, note: String? = nil, accountId: UUID) {
        self.id = id
        self.amount = amount
        self.categoryJSON = Self.encodeCategory(category)
        self.date = date
        self.note = note
        self.accountId = accountId
    }
    
    // Вычисляемое свойство для получения category
    var category: TransactionCategory {
        get {
            if let json = categoryJSON, let decoded = Self.decodeCategory(json) {
                return decoded
            }
            // Возвращаем значение по умолчанию, если не удалось декодировать
            return .cost(.food)
        }
        set {
            categoryJSON = Self.encodeCategory(newValue)
        }
    }
    
    // Вычисляемые свойства
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
    
    // Вспомогательные методы для кодирования/декодирования
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
    
    private static func decodeCategory(_ json: String) -> TransactionCategory? {
        let parts = json.split(separator: ":")
        guard parts.count == 2 else { return nil }
        
        let type = String(parts[0])
        let id = String(parts[1])
        
        switch type {
        case "cost":
            return CostCategory.all.first { $0.id == id }.map { .cost($0) }
        case "income":
            return IncomeCategory.all.first { $0.id == id }.map { .income($0) }
        case "transfer":
            return TransferType.all.first { $0.id == id }.map { .transfer($0) }
        default:
            return nil
        }
    }
}

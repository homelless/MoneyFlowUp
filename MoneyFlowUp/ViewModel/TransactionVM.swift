import Foundation
import SwiftData
import Observation
import SwiftUI


// ViewModel для управления транзакциями.
// Обеспечивает загрузку, добавление, удаление и синхронизацию с SwiftData.
@Observable
@MainActor
final class TransactionVM: Identifiable {

    // Контекст SwiftData для операций с транзакциями
    private let modelContext: ModelContext
    // Актуальный список транзакций (обычно отсортирован по дате)
    var transactions: [Transaction] = []
    
    init(context: ModelContext) {
        self.modelContext = context
        fetchAll()
    }
    
    // Загрузка всех транзакций (по убыванию даты)
    func fetchAll() {
        let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        transactions = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Добавление транзакции и обновление списка
    func addTransaction(_ transaction: Transaction) {
        modelContext.insert(transaction)
        try? modelContext.save()
        fetchAll()
    }
    
    // Удаление транзакции с откатом влияния на баланс соответствующего аккаунта
    func removeTransaction(_ transaction: Transaction, accountVM: AccountViewModel) {
        // Откат влияния на балансы — единый источник расчёта в AccountViewModel
        accountVM.revert(transaction)

        // Удаляем транзакцию из хранилища
        modelContext.delete(transaction)
        try? modelContext.save()
        fetchAll()
    }
}

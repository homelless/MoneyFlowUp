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
        // Находим аккаунт по accountId транзакции
        if let index = accountVM.accounts.firstIndex(where: { $0.id == transaction.accountId }),
           let oldBalance = Double(accountVM.accounts[index].balance) {
            var newBalance = oldBalance
            
            // Корректируем баланс в зависимости от типа транзакции
            switch transaction.category {
            case .cost:
                newBalance += transaction.amount // Возвращаем потраченное
            case .income:
                newBalance -= transaction.amount // Забираем полученное
            case .transfer:
                newBalance += transaction.amount // Простая логика для transfer
            }
            
            accountVM.accounts[index].balance = String(newBalance)
            try? accountVM.modelContext.save()
            accountVM.fetchAll()
        }
        
        // Удаляем транзакцию из хранилища
        modelContext.delete(transaction)
        try? modelContext.save()
        fetchAll()
    }
}


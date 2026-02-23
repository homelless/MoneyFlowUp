import Foundation
import SwiftData
import SwiftUI
import Observation

// ViewModel для управления списком счетов (кошельков).
// Работает на главном акторе, хранит и синхронизирует состояние с хранилищем SwiftData.
@Observable
@MainActor
final class AccountViewModel: Identifiable {
  
    // Контекст SwiftData для операций CRUD
    let modelContext: ModelContext
    // Текущее состояние: список аккаунтов, отсортированных по sortOrder
    var accounts: [Account] = []
    
    init(context: ModelContext) {
        self.modelContext = context
        fetchAll()
    }
    
    // Загрузка всех аккаунтов из хранилища
    func fetchAll() {
        let descriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.sortOrder)])
        accounts = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    // Добавление нового аккаунта и обновление списка
    func addAccount(_ account: Account) {
        modelContext.insert(account)
        try? modelContext.save()
        fetchAll()
    }
    
    // Удаление одного аккаунта по его идентификатору (включая все связанные транзакции:
    // где аккаунт — источник (accountId) ИЛИ получатель (toAccountId))
    func removeAccount(id: UUID) {
        // Находим аккаунт в текущем массиве
        guard let account = accounts.first(where: { $0.id == id }) else { return }
        
        // Удаляем все транзакции, где этот аккаунт фигурирует как источник
        let txFromDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { $0.accountId == id }
        )
        let fromTransactions = (try? modelContext.fetch(txFromDescriptor)) ?? []
        for tx in fromTransactions {
            modelContext.delete(tx)
        }
        
        // Удаляем все транзакции, где этот аккаунт фигурирует как получатель (переводы)
        let txToDescriptor = FetchDescriptor<Transaction>(
            predicate: #Predicate<Transaction> { $0.toAccountId == id }
        )
        let toTransactions = (try? modelContext.fetch(txToDescriptor)) ?? []
        for tx in toTransactions {
            modelContext.delete(tx)
        }
        
        // Удаляем сам аккаунт
        modelContext.delete(account)
        
        // Сохраняем изменения и обновляем список
        try? modelContext.save()
        fetchAll()
    }
    
    // Массовое удаление аккаунтов по индексам (включая их транзакции как источник и как получатель)
    func removeAccounts(at offsets: IndexSet) {
        // Собираем удаляемые аккаунты заранее (чтобы индексы не смещались)
        let accountsToDelete = offsets.compactMap { index in
            accounts.indices.contains(index) ? accounts[index] : nil
        }
        
        // Для каждого аккаунта каскадно удаляем связанные транзакции и сам аккаунт
        for account in accountsToDelete {
            let accountUUID = account.id
            
            // Транзакции, где аккаунт — источник
            let txFromDescriptor = FetchDescriptor<Transaction>(
                predicate: #Predicate<Transaction> { $0.accountId == accountUUID }
            )
            let fromTransactions = (try? modelContext.fetch(txFromDescriptor)) ?? []
            for tx in fromTransactions {
                modelContext.delete(tx)
            }
            
            // Транзакции, где аккаунт — получатель
            let txToDescriptor = FetchDescriptor<Transaction>(
                predicate: #Predicate<Transaction> { $0.toAccountId == accountUUID }
            )
            let toTransactions = (try? modelContext.fetch(txToDescriptor)) ?? []
            for tx in toTransactions {
                modelContext.delete(tx)
            }
            
            // Сам аккаунт
            modelContext.delete(account)
        }
        
        try? modelContext.save()
        fetchAll()
    }
    
    // Перемещение аккаунтов в списке и обновление их sortOrder
    func moveAccount(from source: IndexSet, to destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
        
        for (index, account) in accounts.enumerated() {
            account.sortOrder = index
        }

        try? modelContext.save()
        fetchAll()
    }
    
    // Обновление полей аккаунта по его идентификатору
    func updateAccount(id: UUID, name: String, balance: String, currencyRaw: String, descriptionAccount: String) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].name = name
        accounts[index].balance = balance
        accounts[index].currencyRaw = currencyRaw
        accounts[index].descriptionAccount = descriptionAccount
        try? modelContext.save()
    }
    
    // Общая сумма балансов (числом)
    var totalBalance: Double {
        accounts.reduce(0) { sum, account in
            sum + (Double(account.balance.replacingOccurrences(of: ",", with: ".")) ?? 0)
        }
    }
    
}

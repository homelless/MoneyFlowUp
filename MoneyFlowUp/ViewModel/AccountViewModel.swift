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
    
    // Удаление одного аккаунта по его идентификатору.
    // Связанные транзакции (как источник и как получатель) удаляются каскадно средствами SwiftData.
    func removeAccount(id: UUID) {
        guard let account = accounts.first(where: { $0.id == id }) else { return }
        modelContext.delete(account)
        try? modelContext.save()
        fetchAll()
    }

    // Массовое удаление аккаунтов по индексам (транзакции удаляются каскадно).
    func removeAccounts(at offsets: IndexSet) {
        let accountsToDelete = offsets.compactMap { index in
            accounts.indices.contains(index) ? accounts[index] : nil
        }
        for account in accountsToDelete {
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
    func updateAccount(id: UUID, name: String, balance: Decimal, currencyRaw: String, descriptionAccount: String) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].name = name
        accounts[index].balance = balance
        accounts[index].currencyRaw = currencyRaw
        accounts[index].descriptionAccount = descriptionAccount
        try? modelContext.save()
    }

    // Общая сумма балансов
    var totalBalance: Decimal {
        accounts.reduce(0) { $0 + $1.balance }
    }

    // MARK: - Единый источник изменения баланса
    // Вся арифметика баланса проходит только здесь, чтобы баланс не расходился с историей транзакций.

    // Применить влияние транзакции на балансы кошельков.
    func apply(_ transaction: Transaction) {
        mutateBalances(for: transaction, reverting: false)
    }

    // Откатить влияние транзакции на балансы кошельков.
    func revert(_ transaction: Transaction) {
        mutateBalances(for: transaction, reverting: true)
    }

    // Общая реализация начисления/отката: при reverting знаки инвертируются.
    private func mutateBalances(for transaction: Transaction, reverting: Bool) {
        let amount = Decimal(money: transaction.amount)
        let sign: Decimal = reverting ? -1 : 1

        guard let fromId = transaction.account?.id else { return }

        switch transaction.category {
        case .cost:
            adjust(accountId: fromId, by: -amount * sign)
        case .income:
            adjust(accountId: fromId, by: amount * sign)
        case .transfer:
            // Списываем с источника, зачисляем на получателя
            adjust(accountId: fromId, by: -amount * sign)
            if let toId = transaction.toAccount?.id {
                adjust(accountId: toId, by: amount * sign)
            }
        }

        try? modelContext.save()
        fetchAll()
    }

    // Изменить баланс одного кошелька на delta (без сохранения — сохранение делает вызывающий).
    private func adjust(accountId: UUID, by delta: Decimal) {
        guard let index = accounts.firstIndex(where: { $0.id == accountId }) else { return }
        accounts[index].balance += delta
    }
}

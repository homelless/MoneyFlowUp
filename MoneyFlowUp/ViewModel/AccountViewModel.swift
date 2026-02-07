import Foundation
import SwiftData
import SwiftUI
import Combine
import Observation

@Observable
@MainActor
final class AccountViewModel: Identifiable {
  
    private let modelContext: ModelContext
    var accounts: [Account] = []
    
    init(context: ModelContext) {
        self.modelContext = context
        fetchAll()
    }
    
    func fetchAll() {
        let descriptor = FetchDescriptor<Account>(sortBy: [SortDescriptor(\.sortOrder)])
        accounts = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func addAccount(_ account: Account) {
        modelContext.insert(account)
        try? modelContext.save()
        fetchAll()
    }
    
    func removeAccount(_ account: Account) {
        modelContext.delete(account)
        try? modelContext.save()
        fetchAll()
    }
    

    func removeAccounts(at offsets: IndexSet) {
        for index in offsets {
            let account = accounts[index]
            modelContext.delete(account)
        }
        try? modelContext.save()
        fetchAll()
    }
    
    func moveAccount(from source: IndexSet, to destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
        

        for (index, account) in accounts.enumerated() {
            account.sortOrder = index
        }

        try? modelContext.save()
        fetchAll()
    }
    

    func updateAccount(id: UUID, name: String, balance: String, currencyRaw: String, descriptionAccount: String) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].name = name
        accounts[index].balance = balance
        accounts[index].currencyRaw = currencyRaw
        accounts[index].descriptionAccount = descriptionAccount
        try? modelContext.save()
    }
}

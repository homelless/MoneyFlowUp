import Foundation
import SwiftData
import Observation
import SwiftUI
import Combine

@Observable
@MainActor
final class TransactionVM: Identifiable {

    private let modelContext: ModelContext
    var transactions: [Transaction] = []
    
    init(context: ModelContext) {
        self.modelContext = context
        fetchAll()
    }
    
    func fetchAll() {
        let descriptor = FetchDescriptor<Transaction>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        transactions = (try? modelContext.fetch(descriptor)) ?? []
    }
    
    func addTransaction(_ transaction: Transaction) {
        modelContext.insert(transaction)
        try? modelContext.save()
        fetchAll()
    }
    
    func removeTransaction(_ transaction: Transaction) {
        modelContext.delete(transaction)
        try? modelContext.save()
        fetchAll()
    }
    

}

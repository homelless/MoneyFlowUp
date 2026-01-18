import Foundation
import SwiftData
import Observation
import SwiftUI
import Combine




@Observable
@MainActor
final class TransactionVM: Identifiable {
    var transactions: [Transaction] = [
        // Пример транзакций для тестирования
        Transaction(
            id: UUID(),
            amount: 45.99,
            category: .cost(.food),
            date: Date().addingTimeInterval(-3600),
            note: "Lunch at restaurant",
            accountId: UUID()
        ),
        Transaction(
            id: UUID(),
            amount: 1200.00,
            category: .income(.salary),
            date: Date().addingTimeInterval(-86400),
            note: "Monthly salary",
            accountId: UUID()
        )
    ]
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func removeTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
    }
    
    func transactions(for date: Date) -> [Transaction] {
        let calendar = Calendar.current
        return transactions.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
}

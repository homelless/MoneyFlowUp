import Foundation
import SwiftUI


struct TransactionRow: View {
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 5) {
            // Иконка категории
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(.black)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(transaction.category.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(transaction.amount, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundColor(transaction.isExpense ? .red : .green)
                }
                
                Text(transaction.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview{
    TransactionRow(
        transaction: Transaction(
            id: UUID(),
            amount: 12.34,
            category: .cost(.food),
            date: Date(),
            note: "Обед",
            accountId: UUID()
        )
    )
}

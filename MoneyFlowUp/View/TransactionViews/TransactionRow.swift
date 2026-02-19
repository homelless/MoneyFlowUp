import Foundation
import SwiftUI

// Строка списка транзакций для отображения в List.
// Показывает иконку категории, название, сумму (с цветом по типу), время и опциональную заметку.
struct TransactionRow: View {
    let transaction: Transaction
    let accountName: String
    
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
                    // Название категории
                    Text(transaction.category.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Сумма с форматированием и цветом в зависимости от типа
                    Text(transaction.amount, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundColor(transaction.isExpense ? .red : .green)
                }
                
                // Время транзакции
                Text(transaction.date, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
                // Короткая заметка, если есть
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                Text(accountName)
                    .font(.caption2)
                    .foregroundStyle(.colorMoney)
                    .lineLimit(1)
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
        ), accountName: ""
    )
}


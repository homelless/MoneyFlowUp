import Foundation
import SwiftUI

// Строка списка транзакций для отображения в List.
// Показывает иконку категории, название, сумму (с цветом по типу), время и опциональную заметку.
struct TransactionRow: View {
    let transaction: Transaction
    let accountName: String
    
    var body: some View {
        HStack(spacing: 1) {
            // Иконка категории
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(.текст)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 1) {
           
                    // Название категории
                    Text(transaction.category.name)
                        .font(.headline)
                        .foregroundColor(.текст)
                HStack {

                    // Время транзакции
                    Text(transaction.date, style: .time)
                        .font(.caption)
                        .foregroundColor(.текст2)
                    
                    
                    Spacer()
                    
                    // Сумма с форматированием и цветом в зависимости от типа
                    Text(transaction.amount, format: .currency(code: "USD"))
                        .font(.headline)
                        .foregroundColor(transaction.isExpense ? .red : .green)
                }
                // Короткая заметка, если есть
                if let note = transaction.note, !note.isEmpty {
                    Text(note)
                        .font(.caption)
                        .foregroundColor(.текст2)
                        .lineLimit(1)
                }
                Text(accountName)
                    .font(.caption2)
                    .foregroundStyle(.текст)
                    .lineLimit(1)
                Rectangle()
                    .fill(.текст2) // или другой цвет
                    .frame(height: 0.5)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}


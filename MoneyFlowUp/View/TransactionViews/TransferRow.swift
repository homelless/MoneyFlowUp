import SwiftUI

struct TransferRow: View {
    let from: Account
    let to: Account
    let transaction: Transaction
    
    var body: some View {
        HStack(spacing: 5) {
            Image(systemName: transaction.category.icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 4) {
                Text("\(from.name) → \(to.name)")
                    .font(.headline)
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
            Spacer()
            Text(transaction.amount, format: .currency(code: "USD"))
                .font(.headline)
                .bold()
                .foregroundColor(.blue)
        }
    }
}

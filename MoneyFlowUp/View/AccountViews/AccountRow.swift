import SwiftUI
import SwiftData

// Строка списка кошельков для отображения в списке.
// Показывает иконку, название, баланс и валюту.
struct AccountRow: View {
    let account: Account
   
    var body: some View {
        HStack {
            Image(systemName: "wallet.bifold")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(.black)
                
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                    .foregroundStyle(.black)
                    .lineLimit(1)
                HStack{
                    Text("\(account.balance.description)\(account.currency.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(Color("текст"))

                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    AccountRow(account: Account(id: .init(), name: "test", balance: "1000", currencyRaw: "$", descriptionAccount: ""))
}


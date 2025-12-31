
import SwiftUI

struct AccountDetailView: View {
    
    
    @Bindable var account: Account
    
    var body: some View {
        Form {
            Section("Name wallet") {
                TextField("name", text: $account.name)
                
            }
            Section("Balance") {
                TextField("0", text: $account.balance)
            }
            Section("Currency") {
                Picker("Currency", selection: $account.currencyRaw) {
                    ForEach(Currency.allCases){ currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            }
            Section("Description2") {
                TextEditor(text: $account.descriptionAccount)
                    .frame(height: 200)
            }
        }
        
        
        
    }
}

#Preview {
    AccountDetailView(account: Account(id: .init(), name: "card", balance: "900", currencyRaw: "USD", descriptionAccount: ""))
}

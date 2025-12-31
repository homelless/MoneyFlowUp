//
//  AccountAddView.swift
//  MoneyFlow
//
//  Created by MacBookAir on 24.12.25.
//

import SwiftUI

struct AccountAddView: View {
    
    @Bindable var viewModel: AccountViewModel
    @State var account = Account(id: .init(), name: "", balance: "0", currencyRaw: "", descriptionAccount: "")
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            Section("Name wallet") {
                TextField("name", text: $account.name)
                
            }
            Section("Balance") {
                TextField("0", text: $account.balance)
                    .keyboardType(.decimalPad)
            }
            Section("Currency") {
                Picker("Currency", selection: $account.currencyRaw) {
                    ForEach(Currency.allCases){ currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            }
            Section("Description") {
                TextEditor(text: $account.descriptionAccount)
                    .frame(height: 200)
            }
            Section() {
                Button("Добавить кошелек",) {
                    viewModel.addAccount(account)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .tint(.colorSet)
                .disabled(account.name.trimmingCharacters(in: .whitespaces).isEmpty)
                
            }
        }
    }
}



#Preview {
    AccountAddView(viewModel: AccountViewModel(), account: Account(id: .init(), name: "1", balance: "2", currencyRaw: "$", descriptionAccount: ""))
}

import SwiftUI

struct AccountPickerView: View {
    @Binding var selectedAccount: Account?
    let accounts: [Account]
    let title: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color("фон")
                    .ignoresSafeArea()

                List(accounts) { account in
                    Button(action: {
                        selectedAccount = account
                        dismiss()
                    }) {
                        HStack {
                            Text(account.name)
                                .foregroundColor(Color("текст"))
                            Spacer()
                            Text("\(account.balance.moneyString) \(account.currencyRaw)")
                                .foregroundColor(Color("текст"))
                            if account.id == selectedAccount?.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}

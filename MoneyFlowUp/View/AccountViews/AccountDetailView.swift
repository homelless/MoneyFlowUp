import SwiftUI

// Экран редактирования существующего кошелька.
// Позволяет изменить имя, баланс, валюту и описание, затем сохранить через AccountViewModel.
struct AccountDetailView: View {
    let account: Account
    @Bindable var accountVM: AccountViewModel
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Локальные состояния полей формы с начальными значениями из account
    @State var name: String
    @State var balance: String
    @State var currencyRaw: String
    @State var descriptionAccount: String
    
    init(account: Account, accountVM: AccountViewModel) {
        self.account = account
        self._name = State(initialValue: account.name)
        self._balance = State(initialValue: account.balance)
        self._currencyRaw = State(initialValue: account.currencyRaw)
        self._descriptionAccount = State(initialValue: account.descriptionAccount)
        self.accountVM = accountVM
    }
    
    var body: some View {
        Form {
            // Имя кошелька
            Section("Name wallet") {
                TextField("name", text: $name)
            }
            // Баланс
            Section("Balance") {
                TextField("0", text: $balance)
            }
            // Валюта
            Section("Currency") {
                Picker("Currency", selection: $currencyRaw) {
                    ForEach(Currency.allCases){ currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            }
            // Описание
            Section("Description") {
                TextEditor(text: $descriptionAccount)
                    .frame(height: 200)
            }
            // Кнопка сохранения изменений
            Section {
                Button(action: {
                    accountVM.updateAccount(id: account.id,
                                            name: name,
                                            balance: balance,
                                            currencyRaw: currencyRaw,
                                            descriptionAccount: descriptionAccount)
                    dismiss()
                }) {
                    HStack {
                        Spacer()
                        Text("Сохранить")
                        Spacer()
                    }
                }
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .navigationTitle("Редактировать кошелек")
    }
}


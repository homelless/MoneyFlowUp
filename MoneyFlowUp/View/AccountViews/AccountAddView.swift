import SwiftUI

// Экран добавления нового кошелька.
// Позволяет ввести имя, баланс, валюту и описание, затем сохраняет через AccountViewModel.
struct AccountAddView: View {
    
    // ViewModel для работы с кошельками
    @Bindable var viewModel: AccountViewModel
    // Локальное состояние создаваемого аккаунта
    @State var account = Account(id: .init(), name: "", balance: "", currencyRaw: "", descriptionAccount: "")
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        Form {
            // Имя кошелька
            Section("Название") {
                TextField("", text: $account.name)
            }
            // Начальный баланс
            Section("Баланс") {
                TextField("0", text: $account.balance)
                    .keyboardType(.decimalPad)
            }
            // Выбор валюты
            Section("Валюта") {
                Picker("", selection: $account.currencyRaw) {
                    ForEach(Currency.allCases){ currency in
                        Text(currency.rawValue).tag(currency)
                    }
                }
            }
            // Описание
            Section("Описание") {
                TextEditor(text: $account.descriptionAccount)
                    .frame(height: 200)
            }
            // Кнопка сохранения
            Section() {
                Button("Добавить кошелек",) {
                    viewModel.addAccount(account)
                    dismiss()
                }
                .frame(maxWidth: .infinity)
                .tint(.colorSet)
                // Блокируем кнопку, если имя пустое/из пробелов
                .disabled(account.name.trimmingCharacters(in: .whitespaces).isEmpty)
                .disabled(account.balance.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .navigationTitle(Text("Создание кошелька"))
    }
}


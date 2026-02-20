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
        
        ZStack {
            // Фоновый цвет
            Color("фон").ignoresSafeArea()
            VStack {
                Form {
                    // Имя кошелька
                    Section("Название") {
                        TextField("", text: $account.name)
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Начальный баланс
                    Section("Баланс") {
                        TextField("0", text: $account.balance)
                            .keyboardType(.decimalPad)
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Выбор валюты
                    Section("Валюта") {
                        Picker("", selection: $account.currencyRaw) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.rawValue)
                                    .tag(currency.rawValue) // selection is String, tag must be String
                                    .foregroundColor(.текст)
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    .foregroundColor(.текст)
                    .tint(.текст)
                    // Описание
                    Section("Описание") {
                        ZStack(alignment: .topLeading) {
                            // Placeholder
                            if account.descriptionAccount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Описание(необязательно)")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            TextEditor(text: $account.descriptionAccount)
                                .frame(height: 200)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Кнопка сохранения
                    Section() {
                        Button("Добавить кошелек") {
                            viewModel.addAccount(account)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color("ячейка"))
                        .foregroundStyle(Color("текст"))
                        // Блокируем кнопку, если имя/баланс пустые/из пробелов
                        .disabled(account.name.trimmingCharacters(in: .whitespaces).isEmpty || account.balance.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(Text("Создание кошелька"))
            }
        }
    }
}

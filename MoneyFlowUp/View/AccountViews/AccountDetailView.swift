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
        ZStack {
            // Фоновый цвет
            Color("фон").ignoresSafeArea()
            
            Form {
                // Имя кошелька
                Section("Имя кошелька") {
                    TextField("", text: $name)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
                // Баланс
                Section("Баланс") {
                    TextField("", text: $balance)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
                // Валюта
                Section("Валюта") {
                    Picker("", selection: $currencyRaw) {
                        ForEach(Currency.allCases){ currency in
                            Text(currency.rawValue).tag(currency)
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
                    TextEditor(text: $descriptionAccount)
                        .frame(height: 200)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
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
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .navigationTitle("Редактировать кошелек")
            .scrollContentBackground(.hidden)
        }
    }
}

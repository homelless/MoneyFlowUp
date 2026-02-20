import SwiftUI

// Экран создания новой транзакции типа "Заработок" (доход).
// Позволяет выбрать кошелек, категорию дохода, сумму, дату/время и описание,
// сохраняет транзакцию в хранилище через TransactionVM и обновляет баланс выбранного кошелька.
struct TransactionIncomeView: View {
    // ViewModel со списком кошельков (наблюдаемый через Observation)
    @Bindable var accountVM: AccountViewModel
    // ViewModel для операций с транзакциями (добавление и т.п.)
    @Bindable var transactionVM: TransactionVM
    
    // Локальное состояние формы
    @State private var amount: String = ""                           // Сумма дохода (строкой для ввода)
    @State private var selectedCategory: IncomeCategory?    // Выбранная категория дохода
    @State private var transactionDate: Date = Date()                 // Дата и время транзакции
    @State private var note: String = ""                              // Описание (опционально)
    @State private var selectedAccount: Account?                      // Выбранный кошелек
    @State private var showCategoryPicker = false                     // Флаг показа выбора категории
    @Environment(\.dismiss) private var dismiss                       // Закрытие экрана
    @Environment(\.modelContext) private var modelContext             // Контекст SwiftData (если понадобится)

    // читаем стор доходов из окружения
    @Environment(CategoriesStore<IncomeCategory>.self) private var incomeCategoriesStore
    
    var body: some View {
            ZStack {
                // Фоновый цвет экрана
                Color("фон")
                    .ignoresSafeArea()
                
                Form {
                    // Блок выбора кошелька
                    Section("Кошелек") {
                        Picker("", selection: $selectedAccount) {
                            ForEach(accountVM.accounts) { account in
                                HStack {
                                    Text(account.name)
                                    Spacer()
                                    // Отображаем баланс и валюту выбранного кошелька
                                    Text("\(account.balance) \(account.currencyRaw)")
                                        .foregroundColor(Color("текст"))
                                }
                                .tag(account as Account?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    .listRowBackground(Color("ячейка"))
                     .foregroundStyle(Color("текст"))
                    
                    // Отображение и выбор категории расхода
                    Section("Категория") {
                        if let selectedCategory {
                            HStack {
                                Image(systemName: selectedCategory.icon)
                                    .frame(width: 30)
                                    .foregroundColor(Color("текст"))
                                Text(selectedCategory.name)
                                    .foregroundColor(Color("текст"))
                                Spacer()
                                
                                Button(action: {
                                    showCategoryPicker.toggle()
                                }) {
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color("текст"))
                                        .foregroundStyle(Color("текст"))
                                }
                            }
                        } else {
                            // Нет доступных категорий
                            HStack {
                                Image(systemName: "questionmark.circle")
                                    .frame(width: 30)
                                    .foregroundColor(Color("текст"))
                                Text("Нет доступных категорий")
                                    .foregroundColor(Color("текст"))
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                     .foregroundStyle(Color("текст"))
                    // Блок ввода суммы
                    Section("Сумма") {
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad) // Числовая клавиатура
                    }
                    .listRowBackground(Color("ячейка"))
                     .foregroundStyle(Color("текст"))
                    
                    // Блок выбора даты и времени
                    Section("") {
                        DatePicker("Дата",
                                   selection: $transactionDate,
                                   displayedComponents: [.date, .hourAndMinute])
                        .tint(Color("текст"))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    
                    // Блок ввода описания (необязательно)
                    Section("Описание") {
                        TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    
                    // Кнопка сохранения
                    Section {
                        Button(action: saveTransaction) {
                            HStack {
                                Spacer()
                                Text("Сохранить заработок")
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(!isFormValid)
                        .listRowBackground(isFormValid ? Color("ячейка") : Color.gray.opacity(0.3))
                        .foregroundColor(isFormValid ? Color("текст") : .gray)
                    }
                }
                .scrollContentBackground(.hidden)
                
                
                .toolbar {
                    // Кнопка отмены в навигации
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            dismiss()
                        }
                    }
                }
                // Модальный экран выбора категории дохода
                .sheet(isPresented: $showCategoryPicker) {
                    if let binding = Binding($selectedCategory) {
                        CategoryPickerView(
                            selectedCategory: binding,
                            categories: incomeCategoriesStore.categories,
                            title: "Выберите категорию"
                        )
                    } else {
                        // Если категорий нет — показывать нечего
                        Text("Нет доступных категорий")
                            .padding()
                    }
                }
            }
            .onAppear {
                // При входе выбираем первый кошелек по умолчанию, если еще не выбран
                if selectedAccount == nil, let firstAccount = accountVM.accounts.first {
                    selectedAccount = firstAccount
                }
                ensureValidCategory()
            }
        // Следим за изменениями списка категорий и переустанавливаем выбранную при удалении
        .onChange(of: incomeCategoriesStore.categories) { _ in
            ensureValidCategory()
        }
        }
    
    // Валидация формы: сумма > 0 и выбран кошелек
    private var isFormValid: Bool {
        guard !amount.isEmpty,
              Double(amount) != nil,
              Double(amount)! > 0,
              selectedAccount != nil,
              selectedCategory != nil else {
            return false
        }
        return true
    }
    // Поддерживаем целостность selectedCategory относительно стора
    private func ensureValidCategory() {
        let available = incomeCategoriesStore.categories
        if let current = selectedCategory,
           available.contains(where: { $0.id == current.id }) {
            // все ок, выбранная существует
            return
        }
        // Если текущая не выбрана или удалена — выбрать первую доступную
        selectedCategory = available.first
    }
    
    // Сохранение транзакции дохода и обновление баланса кошелька
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let account = selectedAccount,
              let selectedCategory else { return }
        
        // Формирование модели транзакции (тип: доход)
        let transaction = Transaction(
            id: UUID(),
            amount: amountValue,
            category: .income(selectedCategory),
            date: transactionDate,
            note: note.isEmpty ? nil : note,
            accountId: account.id
        )
        
        // Обновляем баланс аккаунта (+ сумма)
        if let index = accountVM.accounts.firstIndex(where: { $0.id == account.id }) {
            if let currentBalance = Double(account.balance) {
                accountVM.accounts[index].balance = String(currentBalance + amountValue)
            }
        }
        
        // Сохраняем транзакцию через ViewModel и закрываем экран
        transactionVM.addTransaction(transaction)
        amount = ""
        note = ""
        dismiss()
    }
}

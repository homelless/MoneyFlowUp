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
    @State private var selectedCategory: IncomeCategory = .salary     // Выбранная категория дохода
    @State private var transactionDate: Date = Date()                 // Дата и время транзакции
    @State private var note: String = ""                              // Описание (опционально)
    @State private var selectedAccount: Account?                      // Выбранный кошелек
    @State private var showCategoryPicker = false                     // Флаг показа выбора категории
    @Environment(\.dismiss) private var dismiss                       // Закрытие экрана
    @Environment(\.modelContext) private var modelContext             // Контекст SwiftData (если понадобится)
    
    var body: some View {
            ZStack {
                // Фоновый цвет экрана
                Color("ColorSet")
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
                                        .foregroundColor(.secondary)
                                }
                                .tag(account as Account?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    
                    // Блок выбора категории дохода
                    Section("Категории") {
                        HStack {
                            Image(systemName: selectedCategory.icon)
                                .foregroundColor(selectedCategory.color)
                                .frame(width: 30)
                            
                            Text(selectedCategory.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            // Кнопка открытия модального выбора категории
                            Button(action: {
                                showCategoryPicker.toggle()
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Блок ввода суммы
                    Section("Сумма") {
                        HStack {
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad) // Числовая клавиатура
                        }
                    }
                    
                    // Блок выбора даты и времени
                    Section("") {
                        DatePicker("Дата",
                                   selection: $transactionDate,
                                   displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        
                    }
                    
                    // Блок ввода описания (необязательно)
                    Section("Описание") {
                        TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    
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
                        // Деактивируем кнопку, если форма невалидна
                        .disabled(!isFormValid)
                        // Цвет строки зависит от валидности
                        .listRowBackground(isFormValid ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(isFormValid ? .white : .gray)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Новый заработок")
                .navigationBarTitleDisplayMode(.inline)
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
                    CategoryPickerView(
                        selectedCategory: $selectedCategory,
                        categories: IncomeCategory.all,
                        title: "Выберите категорию"
                    )
                }
            }
            .onAppear {
                // При входе выбираем первый кошелек по умолчанию, если еще не выбран
                if selectedAccount == nil, let firstAccount = accountVM.accounts.first {
                    selectedAccount = firstAccount
                }
            }
        }
    
    // Валидация формы: сумма > 0 и выбран кошелек
    private var isFormValid: Bool {
        guard !amount.isEmpty,
              Double(amount) != nil,
              Double(amount)! > 0,
              selectedAccount != nil else {
            return false
        }
        return true
    }
    
    // Сохранение транзакции дохода и обновление баланса кошелька
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let account = selectedAccount else { return }
        
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

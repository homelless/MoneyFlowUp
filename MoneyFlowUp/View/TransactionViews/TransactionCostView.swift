import SwiftUI

// Аннотация файла:
// TransactionCostView.swift — экран создания новой расходной транзакции.
// Позволяет выбрать кошелек, категорию расхода, ввести сумму, дату/время и заметку,
// сохранить транзакцию (уменьшая баланс выбранного кошелька) или отменить ввод.

struct TransactionCostView: View {
    
    // ViewModel для работы со счетами (кошельками)
    @Bindable var accountVM: AccountViewModel
    // ViewModel для работы с транзакциями
    @Bindable var transactionVM: TransactionVM
    
    // Поля формы
    @State private var amount: String = ""                  // сумма расхода (строка для TextField)
    @State private var transactionDate: Date = Date()       // дата и время транзакции
    @State private var selectedCategory: CostCategory?      // выбранная категория расхода
    @State private var note: String = ""                    // заметка к транзакции (опционально)
    @State private var selectedAccount: Account?            // выбранный кошелек
    @State private var showCategoryPicker = false           // показ шита выбора категории
    @Environment(\.dismiss) private var dismiss             // закрытие экрана
    @Environment(\.modelContext) private var modelContext   // контекст SwiftData (если потребуется)

    // ЧИТАЕМ стор расходов из окружения (один общий экземпляр из RootView)
    @Environment(CategoriesStore<CostCategory>.self) private var costCategoriesStore
    
    var body: some View {
        
            ZStack {
                // Фоновый цвет
                Color("фон")
                    .ignoresSafeArea()
                
                // Основная форма ввода данных транзакции
                Form {
                    // Выбор кошелька
                    Section("Кошелек") {
                        Picker("", selection: $selectedAccount) {
                            ForEach(accountVM.accounts) { account in
                                HStack {
                                    Text(account.name)
                                    Spacer()
                                    Text("\(account.balance) \(account.currencyRaw)")
                                        .foregroundColor(Color("текст"))
                                }
                                .tag(account as Account?) // связываем элемент с выбранным Account?
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
                    // Ввод суммы
                    Section("Сумма") {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .listRowBackground(Color("ячейка"))
                     .foregroundStyle(Color("текст"))
                    // Выбор даты и времени
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
                    
                    // Ввод заметки (опционально)
                    Section("Описание") {
                        TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Кнопка сохранения (активна при валидной форме)
                    Section {
                        Button(action: saveTransaction) {
                            HStack {
                                Spacer()
                                Text("Сохранить транзакцию")
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
                

                // Шит выбора категории расходов
                .sheet(isPresented: $showCategoryPicker) {
                    if let binding = Binding($selectedCategory) {
                        CategoryPickerView(
                            selectedCategory: binding,
                            categories: costCategoriesStore.categories,
                            title: "Выберите категорию"
                        )
                    } else {
                        // Если категорий нет — показывать нечего
                        Text("Нет доступных категорий")
                            .padding()
                    }
                }
            }
            // При появлении экрана — автоподстановка первого кошелька, если ничего не выбрано
            .onAppear {
                if selectedAccount == nil, let firstAccount = accountVM.accounts.first {
                    selectedAccount = firstAccount
                }
                ensureValidCategory()
            }
            // Следим за изменениями списка категорий и переустанавливаем выбранную при удалении
            .onChange(of: costCategoriesStore.categories) { _ in
                ensureValidCategory()
            }
        }
    
    // Валидация формы: есть сумма > 0, выбран кошелек и валидная категория
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
        let available = costCategoriesStore.categories
        if let current = selectedCategory,
           available.contains(where: { $0.id == current.id }) {
            // все ок, выбранная существует
            return
        }
        // Если текущая не выбрана или удалена — выбрать первую доступную
        selectedCategory = available.first
    }
    
    // Сохранение расходной транзакции: создание модели, уменьшение баланса кошелька, сохранение через VM
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let account = selectedAccount,
              let selectedCategory else { return }
        
        // Создаем модель транзакции (тип: расход)
        let transaction = Transaction(
            id: UUID(),
            amount: amountValue,
            category: .cost(selectedCategory),
            date: transactionDate,
            note: note.isEmpty ? nil : note,
            accountId: account.id
        )
        
        // Обновляем баланс выбранного кошелька (- сумма)
        if let index = accountVM.accounts.firstIndex(where: { $0.id == account.id }) {
            if let currentBalance = Double(account.balance) {
                accountVM.accounts[index].balance = String(currentBalance - amountValue)
            }
        }

        // Сохраняем транзакцию через ViewModel
        transactionVM.addTransaction(transaction)
        
        // Сброс формы и закрытие экрана
        amount = ""
        note = ""
        dismiss()
    }
}


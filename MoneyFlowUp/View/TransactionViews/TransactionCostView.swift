
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
    @State private var selectedCategory: CostCategory = .food // выбранная категория расхода
    @State private var note: String = ""                    // заметка к транзакции (опционально)
    @State private var selectedAccount: Account?            // выбранный кошелек
    @State private var showCategoryPicker = false           // показ шита выбора категории
    @Environment(\.dismiss) private var dismiss             // закрытие экрана
    @Environment(\.modelContext) private var modelContext   // контекст SwiftData (если потребуется)
    
    
    var body: some View {
        
            ZStack {
                // Фоновый цвет
                Color("ColorSet")
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
                                        .foregroundColor(.secondary)
                                }
                                .tag(account as Account?) // связываем элемент с выбранным Account?
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    // Отображение и выбор категории расхода
                    Section("Категория") {
                        HStack {
                            Image(systemName: selectedCategory.icon)
                                .frame(width: 30)
                            
                            Text(selectedCategory.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                showCategoryPicker.toggle()
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    // Ввод суммы
                    Section("Сумма") {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    
                    // Выбор даты и времени
                    Section("") {
                        DatePicker("Дата",
                                   selection: $transactionDate,
                                   displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        
                    }
                   
                    // Ввод заметки (опционально)
                    Section("Описание") {
                        TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    
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
                        .listRowBackground(isFormValid ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(isFormValid ? .white : .gray)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Новые траты")
                .navigationBarTitleDisplayMode(.inline)
                
                // Кнопка отмены в тулбаре
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            dismiss()
                        }
                    }
                }
                // Шит выбора категории расходов
                .sheet(isPresented: $showCategoryPicker) {
                    CategoryPickerView(
                        selectedCategory: $selectedCategory,
                        categories: CostCategory.all,
                        title: "Выберите категорию"
                    )
                }
            }
            // При появлении экрана — автоподстановка первого кошелька, если ничего не выбрано
            .onAppear {
                if selectedAccount == nil, let firstAccount = accountVM.accounts.first {
                    selectedAccount = firstAccount
                }
            }
        }
    
    // Валидация формы: есть сумма > 0 и выбран кошелек
    private var isFormValid: Bool {
        guard !amount.isEmpty,
              Double(amount) != nil,
              Double(amount)! > 0,
              selectedAccount != nil else {
            return false
        }
        return true
    }
    
    // Сохранение расходной транзакции: создание модели, уменьшение баланса кошелька, сохранение через VM
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let account = selectedAccount else { return }
        
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


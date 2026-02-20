import SwiftUI
import SwiftData

struct TransactionTransferView: View {
    
    @Bindable var accountVM: AccountViewModel
    @Bindable var transactionVM: TransactionVM
    
    @State private var amount: String = ""
    @State private var selectedCategory: TransferType = .accountTransfer
    @State private var transactionDate: Date = Date()
    @State private var note: String = ""
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    @State private var showCategoryPicker = false
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        
            ZStack {
                Color("фон")
                    .ignoresSafeArea()
                
                Form {
                    Section("С кошелька") {
                        Picker("", selection: $fromAccount) {
                            ForEach(accountVM.accounts) { account in
                                HStack {
                                    Text(account.name)
                                    Spacer()
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
                    
                    Section("В кошелек") {
                        Picker("", selection: $toAccount) {
                            ForEach(accountVM.accounts) { account in
                                HStack {
                                    Text(account.name)
                                    Spacer()
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
                    
                    
                    Section("Сумма") {
                        TextField("0", text: $amount)
                            .keyboardType(.decimalPad)
                    }
                    .listRowBackground(Color("ячейка"))
                     .foregroundStyle(Color("текст"))
                    
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
                   
                    
                    Section("Описание") {
                        TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    
                    Section {
                        Button(action: saveTransaction) {
                            HStack {
                                Spacer()
                                Text("Перевод денег")
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
                .navigationTitle("Перевод")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if fromAccount == nil, let firstAccount = accountVM.accounts.first {
                    fromAccount = firstAccount
                }
                if toAccount == nil && accountVM.accounts.count > 1 {
                    toAccount = accountVM.accounts[1]
                }
            }
        }
    
    private var isFormValid: Bool {
        guard !amount.isEmpty,
              Double(amount) != nil,
              Double(amount)! > 0,
              fromAccount != nil,
              toAccount != nil,
              fromAccount?.id != toAccount?.id else {
            return false
        }
        return true
    }
    
    private func saveTransaction() { // Функция сохранения перевода
        // Безопасно извлекаем сумму и выбранные кошельки
        guard let amountValue = Double(amount), // Преобразуем строку суммы в Double
              let fromAcc = fromAccount, // Достаём исходный кошелек
              let toAcc = toAccount else { return } // Достаём целевой кошелек; если что-то не так — выходим
        
        // Создаем одну транзакцию перевода:
        // accountId = исходный кошелек, toAccountId = целевой кошелек.
        // Категория — .transfer с выбранным типом (сейчас .accountTransfer).
        let transferTx = Transaction( // Инициализируем модель транзакции
            id: UUID(), // Генерируем уникальный идентификатор транзакции
            amount: amountValue, // Устанавливаем сумму перевода
            category: .transfer(selectedCategory), // Указываем категорию — перевод с указанным типом
            date: transactionDate, // Дата и время перевода
            note: note.isEmpty ? nil : note, // Если заметка пустая — пишем nil, иначе значение
            accountId: fromAcc.id, // Идентификатор исходного кошелька (откуда списываем)
            toAccountId: toAcc.id // Идентификатор целевого кошелька (куда зачисляем)
        )
        
        // Обновляем балансы обоих аккаунтов:
        // Ищем индексы исходного и целевого кошельков в массиве VM
        if let fromIndex = accountVM.accounts.firstIndex(where: { $0.id == fromAcc.id }), // Находим индекс исходного кошелька
           let toIndex = accountVM.accounts.firstIndex(where: { $0.id == toAcc.id }) { // Находим индекс целевого кошелька
            
            // Балансы в модели Account хранятся строкой, поэтому переводим в Double
            if let fromBalance = Double(accountVM.accounts[fromIndex].balance), // Преобразуем баланс исходного в Double
               let toBalance = Double(accountVM.accounts[toIndex].balance) { // Преобразуем баланс целевого в Double
                
                // Списание с исходного
                accountVM.accounts[fromIndex].balance = String(fromBalance - amountValue) // Вычитаем сумму и сохраняем как строку
                // Зачисление на целевой
                accountVM.accounts[toIndex].balance = String(toBalance + amountValue) // Прибавляем сумму и сохраняем как строку
                
                // Сохраняем изменения в SwiftData через контекст VM
                try? accountVM.modelContext.save() // Пытаемся сохранить изменения модели аккаунтов
                // Перечитываем список аккаунтов (на случай сторонних наблюдателей)
                accountVM.fetchAll() // Обновляем локальный список аккаунтов в VM
            }
        }
        
        // Сохраняем транзакцию в хранилище (SwiftData) через TransactionVM
        transactionVM.addTransaction(transferTx) // Вставляем и сохраняем транзакцию через VM
        // Сбрасываем поля формы
        amount = "" // Очищаем введенную сумму
        note = "" // Очищаем заметку
        // Закрываем экран
        dismiss() // Закрываем представление после сохранения
    }
}

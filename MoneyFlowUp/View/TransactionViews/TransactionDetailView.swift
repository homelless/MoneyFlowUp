import SwiftUI
import SwiftData

// Аннотация файла:
// TransactionDetailView.swift — экран создания/редактирования транзакции.
// Поддерживает группы cost/income/transfer. Группа фиксируется при редактировании и недоступна для смены.

struct TransactionDetailView: View {
    
    // ViewModel для работы со счетами (кошельками)
    @Bindable var accountVM: AccountViewModel
    // ViewModel для работы с транзакциями
    @Bindable var transactionVM: TransactionVM
    
    // Редактируемая транзакция (nil — создание новой)
    private let editingTransaction: Transaction?
    private let isEditing: Bool
    
    // Поля формы
    @State private var amount: String = ""                  // сумма (строка для TextField)
    @State private var transactionDate: Date = Date()       // дата и время
    @State private var selectedCostCategory: CostCategory?  // категория расходов
    @State private var selectedIncomeCategory: IncomeCategory? // категория доходов
    @State private var note: String = ""                    // заметка
    @State private var selectedAccount: Account?            // счет (для cost/income или from для transfer)
    @State private var selectedToAccount: Account?          // целевой счет (для transfer)
    @State private var showCategoryPicker = false           // показ шита выбора категории
    @Environment(\.dismiss) private var dismiss             // закрытие экрана
    @Environment(\.modelContext) private var modelContext   // контекст SwiftData (если потребуется)

    // Stores категорий из окружения
    @Environment(CategoriesStore<CostCategory>.self) private var costCategoriesStore
    @Environment(CategoriesStore<IncomeCategory>.self) private var incomeCategoriesStore
    
    // Группа текущей транзакции (фиксирована при редактировании; при создании — по умолчанию .cost)
    @State private var fixedGroup: TransactionGroup = .cost
    
    init(accountVM: AccountViewModel, transactionVM: TransactionVM, editingTransaction: Transaction? = nil) {
        self._accountVM = Bindable(wrappedValue: accountVM)
        self._transactionVM = Bindable(wrappedValue: transactionVM)
        self.editingTransaction = editingTransaction
        self.isEditing = editingTransaction != nil
    }
    
    var body: some View {
        ZStack {
            Color("фон").ignoresSafeArea()
            
            Form {
                // Группа (read-only)
                Section("Тип") {
                    HStack {
                        Text(fixedGroup.rawValue)
                            .foregroundStyle(Color("текст"))
                        Spacer()
                        Image(systemName: fixedGroup.icon)
                            .foregroundStyle(fixedGroup.color)
                    }
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
                
                // Аккаунты
                if fixedGroup == .transfer {
                    Section("Со счета") {
                        Picker("", selection: $selectedAccount) {
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
                    
                    Section("На счет") {
                        Picker("", selection: $selectedToAccount) {
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
                } else {
                    Section("Кошелек") {
                        Picker("", selection: $selectedAccount) {
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
                }
                
                // Категория для cost/income
                if fixedGroup == .cost || fixedGroup == .income {
                    Section("Категория") {
                        let selectedNameIcon: (String, String) = {
                            switch fixedGroup {
                            case .cost:
                                if let c = selectedCostCategory { return (c.name, c.icon) }
                            case .income:
                                if let c = selectedIncomeCategory { return (c.name, c.icon) }
                            default:
                                break
                            }
                            return ("Нет доступных категорий", "questionmark.circle")
                        }()
                        
                        HStack {
                            Image(systemName: selectedNameIcon.1)
                                .frame(width: 30)
                                .foregroundColor(Color("текст"))
                            Text(selectedNameIcon.0)
                                .foregroundColor(Color("текст"))
                            
                            Spacer()
                            
                            Button(action: { showCategoryPicker.toggle() }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("текст"))
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                }
                
                // Сумма
                Section("Сумма") {
                    TextField("0", text: $amount)
                        .keyboardType(.decimalPad)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
                
                // Дата
                Section("Выберите дату") {
                    CompactDatePicker(title: nil, selection: $transactionDate)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
                
                // Заметка
                Section("Описание") {
                    TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                        .lineLimit(2...4)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
                
                // Сохранить
                Section {
                    Button(action: saveTransaction) {
                        HStack {
                            Spacer()
                            Text(isEditing ? "Сохранить изменения" : "Сохранить транзакцию")
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
            .sheet(isPresented: $showCategoryPicker) {
                if fixedGroup == .cost {
                    if let binding = Binding($selectedCostCategory) {
                        CategoryPickerView(
                            selectedCategory: binding,
                            categories: costCategoriesStore.categories,
                            title: "Выберите категорию расхода"
                        )
                    } else {
                        Text("Нет доступных категорий").padding()
                    }
                } else if fixedGroup == .income {
                    if let binding = Binding($selectedIncomeCategory) {
                        CategoryPickerView(
                            selectedCategory: binding,
                            categories: incomeCategoriesStore.categories,
                            title: "Выберите категорию дохода"
                        )
                    } else {
                        Text("Нет доступных категорий").padding()
                    }
                }
            }
        }
        .onAppear {
            // Автоподстановка счетов
            if selectedAccount == nil, let first = accountVM.accounts.first {
                selectedAccount = first
            }
            if fixedGroup == .transfer, selectedToAccount == nil {
                selectedToAccount = accountVM.accounts.dropFirst().first ?? accountVM.accounts.first
            }
            // Инициализация из редактируемой транзакции
            if let tx = editingTransaction {
                fixedGroup = tx.category.group
                amount = String(tx.amount)
                transactionDate = tx.date
                note = tx.note ?? ""
                if let from = accountVM.accounts.first(where: { $0.id == tx.accountId }) {
                    selectedAccount = from
                }
                if fixedGroup == .transfer, let toId = tx.toAccountId,
                   let to = accountVM.accounts.first(where: { $0.id == toId }) {
                    selectedToAccount = to
                }
                switch tx.category {
                case .cost(let c): selectedCostCategory = c
                case .income(let c): selectedIncomeCategory = c
                case .transfer: break
                }
            } else {
                // Создание новой — по умолчанию .cost
                fixedGroup = .cost
                ensureValidCategoryForGroup()
            }
        }
        .onChange(of: costCategoriesStore.categories) { _ in
            if fixedGroup == .cost { ensureValidCategoryForGroup() }
        }
        .onChange(of: incomeCategoriesStore.categories) { _ in
            if fixedGroup == .income { ensureValidCategoryForGroup() }
        }
    }
    
    // MARK: - Validation
    
    private var isFormValid: Bool {
        guard let amt = Double(amount.replacingOccurrences(of: ",", with: ".")), amt > 0 else { return false }
        switch fixedGroup {
        case .cost:
            return selectedAccount != nil && selectedCostCategory != nil
        case .income:
            return selectedAccount != nil && selectedIncomeCategory != nil
        case .transfer:
            if let from = selectedAccount, let to = selectedToAccount {
                return from.id != to.id
            }
            return false
        }
    }
    
    private func ensureValidCategoryForGroup() {
        switch fixedGroup {
        case .cost:
            let available = costCategoriesStore.categories
            if let current = selectedCostCategory, available.contains(where: { $0.id == current.id }) {
                return
            }
            selectedCostCategory = available.first
        case .income:
            let available = incomeCategoriesStore.categories
            if let current = selectedIncomeCategory, available.contains(where: { $0.id == current.id }) {
                return
            }
            selectedIncomeCategory = available.first
        case .transfer:
            break
        }
    }
    
    // MARK: - Save
    
    private func saveTransaction() {
        guard let amt = Double(amount.replacingOccurrences(of: ",", with: ".")) else { return }
        
        if isEditing, let tx = editingTransaction {
            // Откат старого влияния на балансы
            rollbackBalances(for: tx)
            
            // Применяем новые значения в той же модели (без смены группы)
            tx.amount = amt
            tx.date = transactionDate
            tx.note = note.isEmpty ? nil : note
            
            switch fixedGroup {
            case .cost:
                guard let account = selectedAccount, let cat = selectedCostCategory else { return }
                tx.accountId = account.id
                tx.toAccountId = nil
                tx.category = .cost(cat)
                applyBalances(for: tx)
            case .income:
                guard let account = selectedAccount, let cat = selectedIncomeCategory else { return }
                tx.accountId = account.id
                tx.toAccountId = nil
                tx.category = .income(cat)
                applyBalances(for: tx)
            case .transfer:
                guard let from = selectedAccount, let to = selectedToAccount else { return }
                tx.accountId = from.id
                tx.toAccountId = to.id
                // тип перевода оставляем прежний
                applyBalances(for: tx)
            }
            
            try? modelContext.save()
            transactionVM.fetchAll()
            dismiss()
            return
        }
        
        // Создание новой транзакции
        switch fixedGroup {
        case .cost:
            guard let account = selectedAccount, let cat = selectedCostCategory else { return }
            let newTx = Transaction(
                id: UUID(),
                amount: amt,
                category: .cost(cat),
                date: transactionDate,
                note: note.isEmpty ? nil : note,
                accountId: account.id
            )
            applyBalances(for: newTx)
            transactionVM.addTransaction(newTx)
        case .income:
            guard let account = selectedAccount, let cat = selectedIncomeCategory else { return }
            let newTx = Transaction(
                id: UUID(),
                amount: amt,
                category: .income(cat),
                date: transactionDate,
                note: note.isEmpty ? nil : note,
                accountId: account.id
            )
            applyBalances(for: newTx)
            transactionVM.addTransaction(newTx)
        case .transfer:
            guard let from = selectedAccount, let to = selectedToAccount else { return }
            // Сохраняем тип перевода по умолчанию (единственный пресет)
            let newTx = Transaction(
                id: UUID(),
                amount: amt,
                category: .transfer(.accountTransfer),
                date: transactionDate,
                note: note.isEmpty ? nil : note,
                accountId: from.id,
                toAccountId: to.id
            )
            applyBalances(for: newTx)
            transactionVM.addTransaction(newTx)
        }
        
        dismiss()
    }
    
    // MARK: - Balance helpers
    
    private func rollbackBalances(for tx: Transaction) {
        if tx.isTransfer {
            let amount = tx.amount
            let fromId = tx.accountId
            let toId = tx.toAccountId
            
            if let fromIndex = accountVM.accounts.firstIndex(where: { $0.id == fromId }),
               let fromBalance = Double(accountVM.accounts[fromIndex].balance) {
                accountVM.accounts[fromIndex].balance = String(fromBalance + amount)
            }
            if let toId,
               let toIndex = accountVM.accounts.firstIndex(where: { $0.id == toId }),
               let toBalance = Double(accountVM.accounts[toIndex].balance) {
                accountVM.accounts[toIndex].balance = String(toBalance - amount)
            }
            try? accountVM.modelContext.save()
            accountVM.fetchAll()
        } else {
            if let index = accountVM.accounts.firstIndex(where: { $0.id == tx.accountId }),
               let oldBalance = Double(accountVM.accounts[index].balance) {
                var newBalance = oldBalance
                switch tx.category {
                case .cost:
                    newBalance += tx.amount
                case .income:
                    newBalance -= tx.amount
                case .transfer:
                    break
                }
                accountVM.accounts[index].balance = String(newBalance)
                try? accountVM.modelContext.save()
                accountVM.fetchAll()
            }
        }
    }
    
    private func applyBalances(for tx: Transaction) {
        if tx.isTransfer {
            let amount = tx.amount
            let fromId = tx.accountId
            let toId = tx.toAccountId
            
            if let fromIndex = accountVM.accounts.firstIndex(where: { $0.id == fromId }),
               let fromBalance = Double(accountVM.accounts[fromIndex].balance) {
                accountVM.accounts[fromIndex].balance = String(fromBalance - amount)
            }
            if let toId,
               let toIndex = accountVM.accounts.firstIndex(where: { $0.id == toId }),
               let toBalance = Double(accountVM.accounts[toIndex].balance) {
                accountVM.accounts[toIndex].balance = String(toBalance + amount)
            }
            try? accountVM.modelContext.save()
            accountVM.fetchAll()
        } else {
            if let index = accountVM.accounts.firstIndex(where: { $0.id == tx.accountId }),
               let oldBalance = Double(accountVM.accounts[index].balance) {
                var newBalance = oldBalance
                switch tx.category {
                case .cost:
                    newBalance -= tx.amount
                case .income:
                    newBalance += tx.amount
                case .transfer:
                    break
                }
                accountVM.accounts[index].balance = String(newBalance)
                try? accountVM.modelContext.save()
                accountVM.fetchAll()
            }
        }
    }
}


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
    // Новые состояния для показа шитов выбора аккаунта в стиле TransactionCostView
    @State private var showAccountPicker = false            // для cost/income
    @State private var showFromAccountPicker = false        // для transfer (со счета)
    @State private var showToAccountPicker = false          // для transfer (на счет)
    
    @Environment(\.dismiss) private var dismiss             // закрытие экрана
    @Environment(\.modelContext) private var modelContext   // контекст SwiftData (если потребуется)

    // Stores категорий из окружения
    @Environment(CategoriesStore<CostCategory>.self) private var costCategoriesStore
    @Environment(CategoriesStore<IncomeCategory>.self) private var incomeCategoriesStore
    
    // Группа текущей транзакции (фиксирована при редактировании; при создании — по умолчанию .cost)
    @State private var fixedGroup: TransactionGroup = .cost
    
    // Флаги предупреждений
    @State private var transferAccountsWarning: String?
    
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
                    if accountVM.accounts.count < 2 {
                        Section("Счета для перевода") {
                            Text("Для перевода требуется как минимум два кошелька.")
                                .foregroundStyle(Color("текст"))
                        }
                        .listRowBackground(Color("ячейка"))
                        .foregroundStyle(Color("текст"))
                    } else {
                        Section("Со счета") {
                            Button(action: { showFromAccountPicker = true }) {
                                HStack {
                                    if let selectedAccount {
                                        let balanceText = "\(selectedAccount.balance.moneyString) \(selectedAccount.currencyRaw)"
                                        Text(selectedAccount.name)
                                            .foregroundColor(Color("текст"))
                                        Spacer()
                                        Text(balanceText)
                                            .foregroundColor(Color("текст"))
                                    } else {
                                        Text("Выберите кошелек")
                                            .foregroundColor(.gray)
                                    }
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color("текст"))
                                }
                            }
                        }
                        .listRowBackground(Color("ячейка"))
                        .foregroundStyle(Color("текст"))
                        
                        Section("На счет") {
                            Button(action: { showToAccountPicker = true }) {
                                HStack {
                                    if let selectedToAccount {
                                        let balanceText = "\(selectedToAccount.balance.moneyString) \(selectedToAccount.currencyRaw)"
                                        Text(selectedToAccount.name)
                                            .foregroundColor(Color("текст"))
                                        Spacer()
                                        Text(balanceText)
                                            .foregroundColor(Color("текст"))
                                    } else {
                                        Text("Выберите кошелек")
                                            .foregroundColor(.gray)
                                    }
                                    Image(systemName: "chevron.right")
                                        .foregroundColor(Color("текст"))
                                }
                            }
                        }
                        .listRowBackground(Color("ячейка"))
                        .foregroundStyle(Color("текст"))
                    }
                    
                    if let warning = transferAccountsWarning {
                        Section {
                            Text(warning)
                                .font(.footnote)
                                .foregroundStyle(.orange)
                        }
                        .listRowBackground(Color("ячейка"))
                    }
                } else {
                    Section("Кошелек") {
                        Button(action: { showAccountPicker = true }) {
                            HStack {
                                if let selectedAccount {
                                    let balanceText = "\(selectedAccount.balance) \(selectedAccount.currencyRaw)"
                                    Text(selectedAccount.name)
                                        .foregroundColor(Color("текст"))
                                    Spacer()
                                    Text(balanceText)
                                        .foregroundColor(Color("текст"))
                                } else {
                                    Text("Выберите кошелек")
                                        .foregroundColor(.gray)
                                }
                                Image(systemName: "chevron.right")
                                    .foregroundColor(Color("текст"))
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                }
                
                // Категория для cost/income
                if fixedGroup == .cost || fixedGroup == .income {
                    Section("Категория") {
                        let pair = selectedCategoryNameIcon()
                        
                        HStack {
                            Image(systemName: pair.icon)
                                .frame(width: 30)
                                .foregroundColor(Color("текст"))
                            Text(pair.name)
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
            // Шиты выбора аккаунтов
            .sheet(isPresented: $showAccountPicker) {
                AccountPickerView(
                    selectedAccount: $selectedAccount,
                    accounts: accountVM.accounts,
                    title: "Выберите кошелек"
                )
            }
            .sheet(isPresented: $showFromAccountPicker) {
                AccountPickerView(
                    selectedAccount: $selectedAccount,
                    accounts: accountVM.accounts,
                    title: "Со счета"
                )
            }
            .sheet(isPresented: $showToAccountPicker) {
                AccountPickerView(
                    selectedAccount: $selectedToAccount,
                    accounts: accountVM.accounts,
                    title: "На счет"
                )
            }
            // Шит выбора категории
            .sheet(isPresented: $showCategoryPicker) {
                if fixedGroup == .cost {
                    if let selectedCostCategory {
                        CategoryPickerView(
                            selectedCategory: Binding(
                                get: { selectedCostCategory },
                                set: { newValue in
                                    self.selectedCostCategory = newValue
                                }
                            ),
                            categories: costCategoriesStore.categories,
                            title: "Выберите категорию расхода"
                        )
                    } else {
                        // Если текущая nil — подставим первый доступный, чтобы удовлетворить @Binding non-optional
                        let categories = costCategoriesStore.categories
                        if let first = categories.first {
                            CategoryPickerView(
                                selectedCategory: Binding(
                                    get: { first },
                                    set: { newValue in
                                        self.selectedCostCategory = newValue
                                    }
                                ),
                                categories: categories,
                                title: "Выберите категорию расхода"
                            )
                        } else {
                            Text("Нет доступных категорий").padding()
                        }
                    }
                } else if fixedGroup == .income {
                    if let selectedIncomeCategory {
                        CategoryPickerView(
                            selectedCategory: Binding(
                                get: { selectedIncomeCategory },
                                set: { newValue in
                                    self.selectedIncomeCategory = newValue
                                }
                            ),
                            categories: incomeCategoriesStore.categories,
                            title: "Выберите категорию дохода"
                        )
                    } else {
                        let categories = incomeCategoriesStore.categories
                        if let first = categories.first {
                            CategoryPickerView(
                                selectedCategory: Binding(
                                    get: { first },
                                    set: { newValue in
                                        self.selectedIncomeCategory = newValue
                                    }
                                ),
                                categories: categories,
                                title: "Выберите категорию дохода"
                            )
                        } else {
                            Text("Нет доступных категорий").padding()
                        }
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
                
                // FROM
                let from = tx.account
                // TO
                let to: Account? = (fixedGroup == .transfer) ? tx.toAccount : nil
                
                if let from { selectedAccount = from }
                if let to { selectedToAccount = to }
                
                // Если перевод и какая-то сторона не найдена — безопасно подставляем валидные аккаунты и покажем предупреждение
                if fixedGroup == .transfer {
                    ensureValidTransferSelection(showWarnings: true)
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
            
            // Для не‑transfer тоже убедимся, что selection валиден
            if fixedGroup != .transfer {
                ensureAccountSelectionValid()
            }
        }
        .onChange(of: costCategoriesStore.categories) { _ in
            if fixedGroup == .cost { ensureValidCategoryForGroup() }
        }
        .onChange(of: incomeCategoriesStore.categories) { _ in
            if fixedGroup == .income { ensureValidCategoryForGroup() }
        }
        // Если список аккаунтов меняется — держим selection валидным
        .onChange(of: accountVM.accounts) { _ in
            if fixedGroup == .transfer {
                ensureValidTransferSelection(showWarnings: false)
            } else {
                ensureAccountSelectionValid()
            }
        }
    }
    

    
    private func selectedCategoryNameIcon() -> (name: String, icon: String) {
        switch fixedGroup {
        case .cost:
            if let c = selectedCostCategory { return (c.name, c.icon) }
        case .income:
            if let c = selectedIncomeCategory { return (c.name, c.icon) }
        case .transfer:
            break
        }
        return ("Нет доступных категорий", "questionmark.circle")
    }
    

    
    private var isFormValid: Bool {
        guard let amt = Double(amount.replacingOccurrences(of: ",", with: ".")), amt > 0 else { return false }
        switch fixedGroup {
        case .cost:
            return selectedAccount != nil && selectedCostCategory != nil
        case .income:
            return selectedAccount != nil && selectedIncomeCategory != nil
        case .transfer:
            // Должно быть минимум 2 кошелька и валидная пара from/to
            guard accountVM.accounts.count >= 2 else { return false }
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
    

    
    private func ensureAccountSelectionValid() {
        // Для cost/income: если выбранный кошелек отсутствует в списке — подставить первый доступный
        guard fixedGroup != .transfer else { return }
        if let sel = selectedAccount, accountVM.accounts.contains(where: { $0.id == sel.id }) {
            return
        }
        selectedAccount = accountVM.accounts.first
    }
    
    private func ensureValidTransferSelection(showWarnings: Bool) {
        transferAccountsWarning = nil
        
        // Если счетов меньше двух — сбрасываем selection и предупреждаем
        guard accountVM.accounts.count >= 2 else {
            selectedAccount = accountVM.accounts.first
            selectedToAccount = accountVM.accounts.dropFirst().first
            transferAccountsWarning = "Для перевода требуется как минимум два кошелька."
            return
        }
        
        // FROM: если отсутствует в списке — подставить первый
        if let from = selectedAccount, accountVM.accounts.contains(where: { $0.id == from.id }) == false {
            selectedAccount = accountVM.accounts.first
            if showWarnings {
                transferAccountsWarning = "Исходный кошелек перевода был удален. Выбран первый доступный."
            }
        } else if selectedAccount == nil {
            selectedAccount = accountVM.accounts.first
        }
        
        // TO: если отсутствует в списке — подставить первый, отличный от FROM
        let currentFromId = selectedAccount?.id
        if let to = selectedToAccount, accountVM.accounts.contains(where: { $0.id == to.id }) == false {
            selectedToAccount = accountVM.accounts.first(where: { $0.id != currentFromId }) ?? accountVM.accounts.dropFirst().first
            if showWarnings {
                transferAccountsWarning = "Целевой кошелек перевода был удален. Выбран другой доступный."
            }
        } else if selectedToAccount == nil {
            selectedToAccount = accountVM.accounts.first(where: { $0.id != currentFromId }) ?? accountVM.accounts.dropFirst().first
        }
        
        // Не допускаем одинаковые FROM и TO
        if let from = selectedAccount, let to = selectedToAccount, from.id == to.id {
            selectedToAccount = accountVM.accounts.first(where: { $0.id != from.id }) ?? accountVM.accounts.dropFirst().first
        }
    }
    

    
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
                tx.account = account
                tx.toAccount = nil
                tx.category = .cost(cat)
                applyBalances(for: tx)
            case .income:
                guard let account = selectedAccount, let cat = selectedIncomeCategory else { return }
                tx.account = account
                tx.toAccount = nil
                tx.category = .income(cat)
                applyBalances(for: tx)
            case .transfer:
                guard let from = selectedAccount, let to = selectedToAccount else { return }
                tx.account = from
                tx.toAccount = to
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
                account: account
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
                account: account
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
                account: from,
                toAccount: to
            )
            applyBalances(for: newTx)
            transactionVM.addTransaction(newTx)
        }
        
        dismiss()
    }
    

    
    private func rollbackBalances(for tx: Transaction) {
        // Откат влияния транзакции — единый источник расчёта в AccountViewModel
        accountVM.revert(tx)
    }

    private func applyBalances(for tx: Transaction) {
        // Начисление влияния транзакции — единый источник расчёта в AccountViewModel
        accountVM.apply(tx)
    }
}


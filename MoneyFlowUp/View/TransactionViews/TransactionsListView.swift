import SwiftUI
import SwiftData

// Экран списка транзакций с возможностью:
// - выбрать период (день/неделя/месяц/год/произвольный диапазон),
// - фильтровать по группе (траты/заработок/перевод),
// - посмотреть сумму за период,
// - удалить транзакции,
// - перейти к добавлению транзакции и к другим экранам по маршрутам.

struct TransactionsListView: View {
    // Вью-модель транзакций (Observable), помечена @Bindable для двусторонней связи
    @Bindable var transactionVM: TransactionVM
    // Вью-модель аккаунтов
    @Bindable var accountVM: AccountViewModel
    // Путь навигации (NavigationStack)
    @Binding var path: [Route]
    
    // Выбранная дата (базовая точка для day/week/month/year)
    @State private var selectedDate = Date()
    // Начало и конец кастомного диапазона (для "Период")
    @State private var customStartDate = Calendar.current.startOfDay(for: Date())
    @State private var customEndDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    // Текущий фильтр группы транзакций: nil = все группы
    @State private var selectedFilter: TransactionGroup? = .cost
    // Текущий выбранный период
    @State private var selectedPeriod: Period = .day
    
    // Контекст SwiftData из окружения (если понадобится для операций)
    @Environment(\.modelContext) private var modelContext
    
    // Пример запроса SwiftData (здесь не используется напрямую, так как работаем через transactionVM)
    @Query(sort:\Transaction.date, order: .reverse) var transactions: [Transaction]
    
    // Перечисление периодов для фильтрации
    enum Period: String, CaseIterable, Identifiable {
        case day = "День"
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
        case custom = "Период"
        
        var id: String { rawValue }
    }
    
    // Текущий интервал дат на основе выбранного периода/даты/кастомного диапазона
    private var currentInterval: DateInterval {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            // [startOfDay, startOfNextDay)
            let start = calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .week:
            // [startOfWeek, startOfNextWeek)
            let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .month:
            // [startOfMonth, startOfNextMonth)
            let start = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .year:
            // [startOfYear, startOfNextYear)
            let start = calendar.dateInterval(of: .year, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .custom:
            // Кастомный диапазон: гарантируем start < end,
            // если равны — расширяем на 1 день,
            // конец делаем эксклюзивным (плюс 1 секунда для надежности).
            let start = min(customStartDate, customEndDate)
            let end = max(customStartDate, customEndDate)
            if start == end {
                let endPlus = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                return DateInterval(start: start, end: endPlus)
            }
            let endExclusive = calendar.date(byAdding: .second, value: 1, to: end) ?? end
            return DateInterval(start: start, end: endExclusive)
        }
    }
    
    // Сдвиг текущего периода (стрелки влево/вправо) относительно выбранной даты/диапазона
    private func shiftPeriod(by value: Int) {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            selectedDate = calendar.date(byAdding: .day, value: value, to: selectedDate) ?? selectedDate
        case .week:
            selectedDate = calendar.date(byAdding: .weekOfYear, value: value, to: selectedDate) ?? selectedDate
        case .month:
            selectedDate = calendar.date(byAdding: .month, value: value, to: selectedDate) ?? selectedDate
        case .year:
            selectedDate = calendar.date(byAdding: .year, value: value, to: selectedDate) ?? selectedDate
        case .custom:
            // Для кастомного диапазона сдвигаем обе границы на одинаковое число дней
            if let newStart = calendar.date(byAdding: .day, value: value, to: customStartDate),
               let newEnd = calendar.date(byAdding: .day, value: value, to: customEndDate) {
                customStartDate = newStart
                customEndDate = newEnd
            }
        }
    }
    
    // Отфильтрованные транзакции по текущему интервалу и группе
    var filteredTransactions: [Transaction] {
        let interval = currentInterval
        
        // Берем транзакции из VM и фильтруем по интервалу
        var filtered: [Transaction] = Array(transactionVM.transactions).filter { tx in
            tx.date >= interval.start && tx.date < interval.end
        }
        
        // Дополнительная фильтрация по группе:
        // - nil => все группы (не фильтруем),
        // - для .transfer — по флагу isTransfer,
        // - для остальных — по группе доменной категории.
        if let selectedFilter {
            if selectedFilter == .transfer {
                filtered = filtered.filter { tx in
                    tx.isTransfer
                }
            } else {
                filtered = filtered.filter { tx in
                    tx.category.group == selectedFilter
                }
            }
        }
        // Сортировка по дате убыванию
        return filtered.sorted { $0.date > $1.date }
    }
    
    // Сумма по отфильтрованным транзакциям (знак суммы зависит от сохраненных значений amount)
    var totalAmount: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        ZStack {
            // Фоновый цвет из ассетов
            Color("фон")
                .ignoresSafeArea()
            
            VStack {
                // Верхняя панель: выбор даты/диапазона, периодов, чипы фильтров и итоговая сумма
                VStack(spacing: 16) {
                    Group {
                        switch selectedPeriod {
                        case .custom:
                            // Для кастомного периода показываем два DatePicker'а: начало и конец
                            VStack(spacing: 8) {
                                CompactDatePicker(title: "Начало", selection: $customStartDate)
                                    .foregroundStyle(Color(.текст))
                                    .datePickerStyle(.compact)
                                Rectangle()
                                    .fill(.текст2)
                                    .frame(height: 0.5)
                                
                                CompactDatePicker(title: "Конец", selection: $customEndDate)
                                    .foregroundStyle(Color(.текст))
                                    .datePickerStyle(.compact)
                            }
                            .padding(.horizontal)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                        default:
                            // Для остальных периодов — центральный DatePicker и стрелки сдвига
                            HStack {
                                Button {
                                    shiftPeriod(by: -1)
                                } label: {
                                    Image(systemName: "chevron.left")
                                }
                                Spacer()
                                DatePicker("Дата", selection: $selectedDate, displayedComponents: .date)
                                    .labelsHidden()
                                    .datePickerStyle(.compact)
                                    .environment(\.locale, Locale(identifier: "ru_RU"))
                                Spacer()
                                Button {
                                    shiftPeriod(by: 1)
                                } label: {
                                    Image(systemName: "chevron.right")
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    // Переключатель периода (День/Неделя/Месяц/Год/Период)
                    HStack(spacing: 8) {
                        ForEach(Period.allCases) { period in
                            Button(action: { selectedPeriod = period }) {
                                Text(period.rawValue)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(selectedPeriod == period ? Color("текст2") : Color("ячейка"))
                                    .foregroundColor(.black)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Горизонтальная полоса чипов фильтра по группе транзакций
                    HStack(spacing: 8) {
                        Button(action: { selectedFilter = nil }) {
                            FilterChip(
                                title: "Все",
                                icon: "tray.full",
                                color: .gray,
                                isSelected: selectedFilter == nil
                            )
                        }
                        ForEach(TransactionGroup.allCases, id: \.self) { group in
                            Button(action: { selectedFilter = group }) {
                                FilterChip(
                                    title: group.rawValue,
                                    icon: group.icon,
                                    color: group.color,
                                    isSelected: selectedFilter == group
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Панель "Итого" с суммой и цветовой индикацией по типу
                    if selectedFilter != nil {
                        
                        HStack {
                            Text("Итого:")
                                .font(.headline)
                                .foregroundColor(.текст)
                            Spacer()
                            
                            Text("\(totalAmount, specifier: "%.2f")$")
                                .font(.title2)
                                .bold()
                                .foregroundColor(
                                    {
                                        switch selectedFilter {
                                        case .some(.cost): return .red
                                        case .some(.income): return .green
                                        case .some(.transfer): return .blue
                                        case .none: return .primary
                                        }
                                    }()
                                )
                        }
                        
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background(Color("ячейка"))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
                
                // Пустое состояние, если транзакций нет
                if filteredTransactions.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.текст)
                        
                        Text("Нет транзакций")
                            .font(.title3)
                            .foregroundColor(.текст)
                        
                        Text("Здесь появятся транзакции за выбранный период")
                            .font(.callout)
                            .foregroundColor(.текст)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    // Список транзакций
                    List {
                        ForEach(filteredTransactions) { transaction in
                            Button {
                                path.append(.transactionsDetail(transaction.id))
                            } label: {
                                if selectedFilter == .transfer {
                                    // Для перевода пробуем отрисовать специализированную строку с обоими аккаунтами
                                    if let from = transaction.account, let to = transaction.toAccount {
                                        TransferRow(from: from, to: to, transaction: transaction)
                                            .listRowBackground(Color.clear)
                                    } else {
                                        // Если не удалось найти оба аккаунта — fallback к обычной строке
                                        let accountName = transaction.account?.name ?? "—"
                                        TransactionRow(transaction: transaction, accountName: accountName)
                                            .listRowBackground(Color.clear)
                                    }
                                } else {
                                    // Для "Все" и других фильтров: если это перевод — тоже показываем TransferRow
                                    if transaction.isTransfer,
                                       let from = transaction.account,
                                       let to = transaction.toAccount {
                                        TransferRow(from: from, to: to, transaction: transaction)
                                            .listRowBackground(Color.clear)
                                    } else {
                                        // Для трат/доходов — обычная строка транзакции
                                        let accountName = transaction.account?.name ?? "—"
                                        TransactionRow(transaction: transaction, accountName: accountName)
                                            .listRowBackground(Color.clear)
                                    }
                                }
                            }
                        }
                        // Удаление свайпом
                        .onDelete(perform: deleteTransactions)
                        .buttonStyle(.plain)
                        .tint(.clear)
                        .frame(height: 65)
                        .contentShape(Rectangle())
                        .listRowBackground(Color.clear)
                        .listRowInsets(.none)
                        .listRowSeparator(.hidden)
                    }
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .listStyle(.plain)
                }
            }
            // Навигация по маршрутам
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .addAccount:
                    AccountAddView(viewModel: accountVM)
                case .detail(let accountID):
                    if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                        AccountDetailView(account: account, accountVM: accountVM)
                    } else {
                        Text("Кошелек не найден")
                    }
                case .addTransaction:
                    TransactionView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
                case .calendar(let date):
                    TransactionsCalendarView(selectedDate: date, transactionVM: transactionVM, accountVM: accountVM, path: $path)
                case .accountTransactions(let accountID):
                    if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                        AccountTransactionsView(transactionVM: transactionVM, accountVM: accountVM, path: $path, accountID: accountID)
                    } else {
                        Text("Кошелек не найден")
                    }
                case .transactionsDetail(let txID):
                    if let tx = transactionVM.transactions.first(where: { $0.id == txID }) {
                        TransactionDetailView(accountVM: accountVM, transactionVM: transactionVM, editingTransaction: tx)
                    } else {
                        Text("Транзакция не найдена")
                    }
                }
            }
            // Кнопка «добавить транзакцию» внизу (safe area inset)
            .safeAreaInset(edge: .bottom) {
                GeometryReader { proxy in
                    HStack {
                        Spacer()
                        Button(action: {
                            path.append(.addTransaction)
                        }) {
                            Text("добавить транзакцию")
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .minimumScaleFactor(0.9)
                                .frame(width: proxy.size.width * 0.85, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color("текст2")).opacity(0.9)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color("текст"), lineWidth: 1)
                                )
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 20))
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 8)
                    .padding(.bottom, 16)
                }
                .frame(height: 50 + 8 + 16)
            }
        }
    }
    // Удаление выбранных транзакций из списка (проксирует в VM, которая корректирует балансы)
    private func deleteTransactions(at offsets: IndexSet) {
        let items = filteredTransactions
        for index in offsets {
            let tx = items[index]
            transactionVM.removeTransaction(tx, accountVM: accountVM)
        }
    }
    
}

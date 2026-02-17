import SwiftUI
import SwiftData

struct TransactionsListView: View {
    // ViewModel-ы, проброшенные извне, для работы с транзакциями и счетами
    @Bindable var transactionVM: TransactionVM
    @Bindable var accountVM: AccountViewModel
    // Навигационный путь для NavigationStack
    @Binding var path: [Route]
    // Выбранная дата-«якорь» для периодов (день/неделя/месяц/год)
    @State private var selectedDate = Date()
    // Кастомный период (если выбран .custom)
    @State private var customStartDate = Calendar.current.startOfDay(for: Date())
    @State private var customEndDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date())) ?? Date()
    // Выбранный фильтр по группе транзакций (например, расход/доход)
    @State private var selectedFilter: TransactionGroup = .cost
    // Выбранный период
    @State private var selectedPeriod: Period = .day
    // Контекст модели SwiftData (для операций с данными при необходимости)
    @Environment(\.modelContext) private var modelContext
    
    // Пример запроса SwiftData (в этом экране используем transactionVM.transactions, но запрос оставлен)
    @Query(sort:\Transaction.date, order: .reverse) var transactions: [Transaction]
    
    enum Period: String, CaseIterable, Identifiable {
        case day = "День"
        case week = "Неделя"
        case month = "Месяц"
        case year = "Год"
        case custom = "Период"
        
        var id: String { rawValue }
    }
    
    // Вычисление начала и конца интервала по выбранному периоду
    private var currentInterval: DateInterval {
        let calendar = Calendar.current
        switch selectedPeriod {
        case .day:
            let start = calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .day, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .week:
            let start = calendar.dateInterval(of: .weekOfYear, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .weekOfYear, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .month:
            let start = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .month, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .year:
            let start = calendar.dateInterval(of: .year, for: selectedDate)?.start ?? calendar.startOfDay(for: selectedDate)
            let end = calendar.date(byAdding: .year, value: 1, to: start)!
            return DateInterval(start: start, end: end)
        case .custom:
            // Гарантируем, что start <= end
            let start = min(customStartDate, customEndDate)
            let end = max(customStartDate, customEndDate)
            // Если одинаковые — расширим на 1 день, чтобы не получить пустой интервал
            if start == end {
                let endPlus = calendar.date(byAdding: .day, value: 1, to: start) ?? start
                return DateInterval(start: start, end: endPlus)
            }
            // Конец делаем «исключительным», добавив 1 секунду
            let endExclusive = calendar.date(byAdding: .second, value: 1, to: end) ?? end
            return DateInterval(start: start, end: endExclusive)
        }
    }
    
    // Сдвиг текущего периода влево/вправо
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
            // Для кастомного периода смещаем обе границы
            if let newStart = calendar.date(byAdding: .day, value: value, to: customStartDate),
               let newEnd = calendar.date(byAdding: .day, value: value, to: customEndDate) {
                customStartDate = newStart
                customEndDate = newEnd
            }
        }
    }
    
    // Вычисляемый список транзакций, отфильтрованный по периоду и группе
    var filteredTransactions: [Transaction] {
        let interval = currentInterval
        var filtered = transactionVM.transactions.filter { tx in
            tx.date >= interval.start && tx.date < interval.end
        }
        filtered = filtered.filter { transaction in
            transaction.category.group == selectedFilter
        }
        return filtered.sorted { $0.date > $1.date }
    }

    // Итоговая сумма по отфильтрованным транзакциям
    var totalAmount: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    var body: some View {
        ZStack {
            // Фоновый цвет экрана
            Color("ColorSet")
                .ignoresSafeArea()
            
            VStack {
                // Верхняя панель с выбором дат/интервала (выше), затем выбор периода, затем фильтры и блок "Итого"
                VStack(spacing: 16) {
                    
                    // Управление датой/интервалом (поднято выше)
                    Group {
                        switch selectedPeriod {
                        case .custom:
                            VStack(spacing: 8) {
                                DatePicker("Начало", selection: $customStartDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                                DatePicker("Конец", selection: $customEndDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            .padding(.horizontal)
                            .environment(\.locale, Locale(identifier: "ru_RU"))
                        default:
                            HStack {
                                Button {
                                    shiftPeriod(by: -1)
                                } label: {
                                    Image(systemName: "chevron.left")
                                }
                                Spacer()
                                // Якорная дата
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
                    
                    // Выбор периода (опущен ниже)
                    Picker("Период", selection: $selectedPeriod) {
                        ForEach(Period.allCases) { period in
                            Text(period.rawValue).tag(period)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // Горизонтальный список чипов-фильтров по группам транзакций
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
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
                    }
                    
                    // Блок отображения итоговой суммы за выбранный период и группу
                    HStack {
                        Text("Итого:")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(totalAmount, specifier: "%.2f")$")
                            .font(.title2)
                            .bold()
                            .foregroundColor(selectedFilter == .cost ? .red : .green)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                // Состояние пустого списка или отображение списка транзакций
                if filteredTransactions.isEmpty {
                    Spacer()
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Нет транзакций")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Здесь появятся транзакции за выбранный период")
                            .font(.callout)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    Spacer()
                } else {
                    // Список транзакций с возможностью удаления
                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                    .listStyle(.plain)
                    .background(Color("ColorSet"))
                }
            }
        }
        // Заголовок и стиль навигации
        .navigationTitle("Транзакции")
        .navigationBarTitleDisplayMode(.inline)
        // Маршрутизация к различным экранам приложения
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .addTransaction:
                TransactionView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
                
            case .detail(let accountID):
                if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                    AccountDetailView(account: account, accountVM: accountVM)
                    
                } else {
                    Text("Кошелек не найден")
                }
            case .addAccount:
                AccountAddView(viewModel: accountVM)
            case .calendar(let date):
                TransactionsCalendarView(selectedDate: date, transactionVM: transactionVM, accountVM: accountVM)
            }
        }
        
        // Кнопка добавления транзакции, закрепленная внизу экрана
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
                                    .fill(Color("addColor")).opacity(0.9)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
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

    // Удаление транзакций из отфильтрованного списка и обновление данных через ViewModel
    private func deleteTransactions(at offsets: IndexSet) {
        let items = filteredTransactions
        for index in offsets {
            let tx = items[index]
            transactionVM.removeTransaction(tx, accountVM: accountVM)
        }
    }
}

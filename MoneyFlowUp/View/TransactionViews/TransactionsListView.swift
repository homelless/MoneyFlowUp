
import SwiftUI
import SwiftData

struct TransactionsListView: View {
    // ViewModel-ы, проброшенные извне, для работы с транзакциями и счетами
    @Bindable var transactionVM: TransactionVM
    @Bindable var accountVM: AccountViewModel
    // Навигационный путь для NavigationStack
    @Binding var path: [Route]
    // Выбранная дата для фильтрации
    @State private var selectedDate = Date()
    // Выбранный фильтр по группе транзакций (например, расход/доход)
    @State private var selectedFilter: TransactionGroup = .cost
    // Контекст модели SwiftData (для операций с данными при необходимости)
    @Environment(\.modelContext) private var modelContext
    
    // Пример запроса SwiftData (в этом экране используем transactionVM.transactions, но запрос оставлен)
    @Query(sort:\Transaction.date, order: .reverse) var transactions: [Transaction]
    
    // Вычисляемый список транзакций, отфильтрованный по дате и группе
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        // Фильтрация по выбранной дате (в рамках суток)
        var filtered = transactionVM.transactions.filter { transaction in
            transaction.date >= startOfDay && transaction.date < endOfDay
        }

        // Фильтрация по выбранной группе (расход/доход и т.п.)
        filtered = filtered.filter { transaction in
            transaction.category.group == selectedFilter
        }

        // Сортировка по дате по убыванию
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
                // Верхняя панель с выбором даты, фильтрами и блоком "Итого"
                VStack(spacing: 16) {
                    // Выбор даты (только дата, без времени)
                    DatePicker("Выберите дату", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                        .environment(\.locale, Locale(identifier: "ru_RU"))

                    
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
                    
                    // Блок отображения итоговой суммы за выбранную дату и группу
                    HStack {
                        Text("Итого:")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("\(totalAmount, specifier: "%.2f")$")
                            .font(.title2)
                            .bold()
                            // Цвет суммы зависит от типа: расход — красный, доход — зеленый
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
                    
                    // Заглушка при отсутствии транзакций на выбранную дату/фильтр
                    VStack(spacing: 16) {
                        Image(systemName: "list.bullet.rectangle")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        
                        Text("Нет транзакций")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        
                        Text("Здесь появятся транзакции на выбранную дату")
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
                        // Переход к экрану добавления транзакции
                        path.append(.addTransaction)
                    }) {
                        Text("добавить транзакцию")
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .frame(width: proxy.size.width * 0.85, height: 50) // 90% ширины, фиксированная высота
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




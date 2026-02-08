import SwiftUI

// Экран календаря: выбор даты и просмотр транзакций за день.
// Можно фильтровать по группе транзакций, удалять элементы.
struct TransactionsCalendarView: View {
    
    @State private var selectedDate = Date()
    @State private var selectedFilter: TransactionGroup?
    
    @Bindable var transactionVM: TransactionVM
    @Bindable var accountVM: AccountViewModel
    @Environment(\.modelContext) private var modelContext
    
    // Кастомный init для установки начальной даты извне
    init(selectedDate: Date = Date(), transactionVM: TransactionVM, accountVM: AccountViewModel) {
        self._selectedDate = State(initialValue: selectedDate)
        self.transactionVM = transactionVM
        self.accountVM = accountVM
    }
    
    // Отфильтрованные транзакции за выбранный день с учетом опционального фильтра по группе
    var filteredTransactions: [Transaction] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        var filtered = transactionVM.transactions.filter { transaction in
            transaction.date >= startOfDay && transaction.date < endOfDay
        }

        if let filter = selectedFilter {
            filtered = filtered.filter { transaction in
                transaction.category.group == filter
            }
        }

        return filtered.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
            VStack {
                // Графический дата-пикер
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .environment(\.locale, Locale(identifier: "ru_RU"))

                VStack {
                    // Разделитель
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 0.5)
                    
                    // Фильтры по группе транзакций
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
                        .padding(.horizontal, 25)
                    }
                    
                    // Пустое состояние или список транзакций
                    if filteredTransactions.isEmpty {
                        VStack(spacing: 16) {
                            Image(systemName: "list.bullet.rectangle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                                .padding(.top, 40)
                            
                            Text("Нет транзакций")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Здесь появятся транзакции на выбранную дату")
                                .font(.callout)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }
                        
                    } else {
                        List {
                            ForEach(filteredTransactions) { transaction in
                                TransactionRow(transaction: transaction)
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                            }
                            // Удаление транзакции из календарного списка
                            .onDelete(perform: deleteTransaction)
                        }
                        .listStyle(.plain)
                        .background(Color("ColorSet"))
                    }
                    Spacer()
                }
                
            }
            .navigationTitle("Календарь")
        }
    }
    // Удаление транзакции и откат баланса через VM
    private func deleteTransaction(_ offsets: IndexSet) {
        for index in offsets {
            let transaction = filteredTransactions[index]
            transactionVM.removeTransaction(transaction, accountVM: accountVM)
        }
    }
}


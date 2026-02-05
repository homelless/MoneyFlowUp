import SwiftUI

struct TransactionsListView: View {
    @Bindable var transactionVM: TransactionVM
    @Bindable var accountVM: AccountViewModel
    @Binding var path: [Route]
    @State private var selectedDate = Date()
    @State private var selectedFilter: TransactionGroup?
    
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

    var totalAmount: Double {
        filteredTransactions.reduce(0) { $0 + $1.amount }
    }

    
    var body: some View {
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
            VStack {
                VStack(spacing: 16) {
                    DatePicker("Выберите дату", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                        .padding(.horizontal)
                    
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
                    
                    HStack {
                        Text("Итого:")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("$\(totalAmount, specifier: "%.2f")")
                            .font(.title2)
                            .bold()
                            .foregroundColor(totalAmount >= 0 ? .green : .red)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                .padding(.vertical)
                
                if filteredTransactions.isEmpty {
                    Spacer()
                    
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
                    List {
                        ForEach(filteredTransactions) { transaction in
                            TransactionRow(transaction: transaction)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                        .onDelete(perform: deleteTransaction)
                    }
                    .listStyle(.plain)
                    .background(Color("ColorSet"))
                }
            }
        }
        .navigationTitle("Транзакции")
        .navigationBarTitleDisplayMode(.inline)
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
                
            }
        }
        
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
            .frame(height: 50 + 8 + 16) // высота inset под кнопку и отступы
        }
    }

    private func deleteTransaction(at offsets: IndexSet) {
        transactionVM.removeTransaction(at: offsets)
    }
}

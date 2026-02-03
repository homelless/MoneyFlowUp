import SwiftUI

struct TransactionsListView: View {
    
    @Bindable var transactionVM: TransactionVM
    @Bindable var accountVM: AccountViewModel
    @State private var selectedDate = Date()
    @State private var selectedFilter: TransactionGroup?
    @State private var path: [Route] = []
    
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
        NavigationStack(path: $path) {
            ZStack {
                Color("ColorSet")
                    .ignoresSafeArea()
                
                VStack {
                    VStack(spacing: 16) {
                        DatePicker("Выберите дату", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                            .padding(.horizontal)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                Button(action: { selectedFilter = nil }) {
                                    FilterChip(title: "All", isSelected: selectedFilter == nil)
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
                    
                    GeometryReader { geo in
                        VStack {
                            Spacer()
                            Button(action: {
                                path.append(.addTransaction)
                            }) {
                                Text("добавить транзакцию")
                                    .foregroundColor(.black)
                                    .frame(width: 360, height: 50)
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
                            .zIndex(1)
                            .padding(.bottom, geo.safeAreaInsets.bottom + 100)
                        }
                        .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                    }
                    .ignoresSafeArea()
                }
            }
            .navigationTitle("Транзакции")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .addTransaction:
                    TransactionView(transactionVM: transactionVM, accountVM: accountVM)
                     
                case .detail(let accountID):
                    if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                        AccountDetailView(account: account)
                            
                    } else {
                        Text("Кошелек не найден")
                    }
                case .addAccount:
                    AccountAddView(viewModel: accountVM)
                        
                }
            }
        }
    }
    
    private func deleteTransaction(at offsets: IndexSet) {
        transactionVM.removeTransaction(at: offsets)
    }
}

import SwiftUI

struct TransactionsListView: View {
    
    @Bindable var transactionVM: TransactionVM
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
                    // Фильтры и дата
                    VStack(spacing: 16) {
                        DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
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
                            Text("Total:")
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
                            
                            Text("No transactions")
                                .font(.title3)
                                .foregroundColor(.secondary)
                            
                            Text("Transactions for selected date will appear here")
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
            .navigationTitle("Transactions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
            }
        }
    
    
    private func deleteTransaction(at offsets: IndexSet) {
        transactionVM.removeTransaction(at: offsets)
    }
}



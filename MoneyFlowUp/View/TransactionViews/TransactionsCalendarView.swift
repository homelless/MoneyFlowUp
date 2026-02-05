//
//  TransactionsCalendarView.swift
//  MoneyFlowUp
//
//  Created by MacBookAir on 5.02.26.
//

import SwiftUI

struct TransactionsCalendarView: View {
    
    @State private var selectedDate = Date()
    @State private var selectedFilter: TransactionGroup?
    
    @Bindable var transactionVM: TransactionVM
    @Bindable var accountVM: AccountViewModel
    
    // Новый инициализатор, чтобы открыть экран сразу на нужной дате
    init(selectedDate: Date = Date(), transactionVM: TransactionVM, accountVM: AccountViewModel) {
        self._selectedDate = State(initialValue: selectedDate)
        self.transactionVM = transactionVM
        self.accountVM = accountVM
    }
    
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
                DatePicker("", selection: $selectedDate, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                
                
                
                VStack {
                    Rectangle()
                        .fill(Color.black)
                        .frame(height: 0.5)
                    
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
    private func deleteTransaction(at offsets: IndexSet) {
        transactionVM.removeTransaction(at: offsets)
    }
    
}

#Preview {
    let transactionVM = TransactionVM()
    let accountVM = AccountViewModel()
    return TransactionsCalendarView(transactionVM: transactionVM, accountVM: accountVM)
}


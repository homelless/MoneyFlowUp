import SwiftUI

struct TransactionTransferView: View {
    @Bindable var accountVM: AccountViewModel
    @Bindable var transactionVM: TransactionVM
    
    @State private var amount: String = ""
    @State private var selectedCategory: TransferType = .accountTransfer
    @State private var transactionDate: Date = Date()
    @State private var note: String = ""
    @State private var fromAccount: Account?
    @State private var toAccount: Account?
    @State private var showCategoryPicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("ColorSet")
                    .ignoresSafeArea()
                
                Form {
                    Section("From Account") {
                        Picker("Select account", selection: $fromAccount) {
                            ForEach(accountVM.accounts) { account in
                                HStack {
                                    Text(account.name)
                                    Spacer()
                                    Text("\(account.balance) \(account.currencyRaw)")
                                        .foregroundColor(.secondary)
                                }
                                .tag(account as Account?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    
                    Section("To Account") {
                        Picker("Select account", selection: $toAccount) {
                            ForEach(accountVM.accounts) { account in
                                HStack {
                                    Text(account.name)
                                    Spacer()
                                    Text("\(account.balance) \(account.currencyRaw)")
                                        .foregroundColor(.secondary)
                                }
                                .tag(account as Account?)
                            }
                        }
                        .pickerStyle(.navigationLink)
                    }
                    
                    Section("Amount") {
                        HStack {
                            Text("$")
                                .foregroundColor(.secondary)
                            
                            TextField("0.00", text: $amount)
                                .keyboardType(.decimalPad)
                                .font(.title2)
                                .bold()
                        }
                    }
                    
                    Section("Date") {
                        DatePicker("Transaction date",
                                   selection: $transactionDate,
                                   displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                    }
                    
                    Section("Notes") {
                        TextField("Add note (optional)", text: $note, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    
                    Section {
                        Button(action: saveTransaction) {
                            HStack {
                                Spacer()
                                Text("Transfer Money")
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(!isFormValid)
                        .listRowBackground(isFormValid ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(isFormValid ? .white : .gray)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Transfer")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
            .onAppear {
                if fromAccount == nil, let firstAccount = accountVM.accounts.first {
                    fromAccount = firstAccount
                }
                if toAccount == nil && accountVM.accounts.count > 1 {
                    toAccount = accountVM.accounts[1]
                }
            }
        }
    }
    
    private var isFormValid: Bool {
        guard !amount.isEmpty,
              Double(amount) != nil,
              Double(amount)! > 0,
              fromAccount != nil,
              toAccount != nil,
              fromAccount?.id != toAccount?.id else {
            return false
        }
        return true
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let fromAcc = fromAccount,
              let toAcc = toAccount else { return }
        
        // Создаем две транзакции (исходящую и входящую)
        let fromTransaction = Transaction(
            id: UUID(),
            amount: amountValue,
            category: .transfer(selectedCategory),
            date: transactionDate,
            note: note.isEmpty ? nil : "Transfer to \(toAcc.name)",
            accountId: fromAcc.id
        )
        
        let toTransaction = Transaction(
            id: UUID(),
            amount: amountValue,
            category: .transfer(selectedCategory),
            date: transactionDate,
            note: note.isEmpty ? nil : "Transfer from \(fromAcc.name)",
            accountId: toAcc.id
        )
        
        // Обновляем балансы счетов
        if let fromIndex = accountVM.accounts.firstIndex(where: { $0.id == fromAcc.id }),
           let toIndex = accountVM.accounts.firstIndex(where: { $0.id == toAcc.id }) {
            
            if let fromBalance = Double(fromAcc.balance),
               let toBalance = Double(toAcc.balance) {
                
                accountVM.accounts[fromIndex].balance = String(fromBalance - amountValue)
                accountVM.accounts[toIndex].balance = String(toBalance + amountValue)
            }
        }
        
        transactionVM.addTransaction(fromTransaction)
        transactionVM.addTransaction(toTransaction)
        dismiss()
    }
}

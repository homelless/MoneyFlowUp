import SwiftUI

struct TransactionIncomeView: View {
    @Bindable var accountVM: AccountViewModel
    @Bindable var transactionVM: TransactionVM
    
    @State private var amount: String = ""
    @State private var selectedCategory: IncomeCategory = .salary
    @State private var transactionDate: Date = Date()
    @State private var note: String = ""
    @State private var selectedAccount: Account?
    @State private var showCategoryPicker = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
            ZStack {
                Color("ColorSet")
                    .ignoresSafeArea()
                
                Form {
                    Section("Кошелек") {
                        Picker("", selection: $selectedAccount) {
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
                    
                    Section("Категории") {
                        HStack {
                            Image(systemName: selectedCategory.icon)
                                .foregroundColor(selectedCategory.color)
                                .frame(width: 30)
                            
                            Text(selectedCategory.name)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Button(action: {
                                showCategoryPicker.toggle()
                            }) {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    
                    Section("Сумма") {
                        HStack {
                            TextField("0", text: $amount)
                                .keyboardType(.decimalPad)
                        }
                    }
                    
                    Section("") {
                        DatePicker("Дата",
                                   selection: $transactionDate,
                                   displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .environment(\.locale, Locale(identifier: "ru_RU"))
                        
                    }
                    
                    Section("Описание") {
                        TextField("Добавьте описание(опционально)", text: $note, axis: .vertical)
                            .lineLimit(2...4)
                    }
                    
                    Section {
                        Button(action: saveTransaction) {
                            HStack {
                                Spacer()
                                Text("Сохранить заработок")
                                    .bold()
                                Spacer()
                            }
                        }
                        .disabled(!isFormValid)
                        .listRowBackground(isFormValid ? Color.green : Color.gray.opacity(0.3))
                        .foregroundColor(isFormValid ? .white : .gray)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle("Новый заработок")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Отмена") {
                            dismiss()
                        }
                    }
                }
                .sheet(isPresented: $showCategoryPicker) {
                    CategoryPickerView(
                        selectedCategory: $selectedCategory,
                        categories: IncomeCategory.all,
                        title: "Выберите категорию"
                    )
                }
            }
            .onAppear {
                if selectedAccount == nil, let firstAccount = accountVM.accounts.first {
                    selectedAccount = firstAccount
                }
            }
        }
    
    
    private var isFormValid: Bool {
        guard !amount.isEmpty,
              Double(amount) != nil,
              Double(amount)! > 0,
              selectedAccount != nil else {
            return false
        }
        return true
    }
    
    private func saveTransaction() {
        guard let amountValue = Double(amount),
              let account = selectedAccount else { return }
        
        let transaction = Transaction(
            id: UUID(),
            amount: amountValue,
            category: .income(selectedCategory),
            date: transactionDate,
            note: note.isEmpty ? nil : note,
            accountId: account.id
        )
        
        // Обновляем баланс счета
        if let index = accountVM.accounts.firstIndex(where: { $0.id == account.id }) {
            if let currentBalance = Double(account.balance) {
                accountVM.accounts[index].balance = String(currentBalance + amountValue)
            }
        }
        
        transactionVM.addTransaction(transaction)
        dismiss()
    }
}



//
//  TransactionCostView.swift
//  MoneyFlow
//
//  Created by MacBookAir on 31.12.25.
//

import SwiftUI

struct TransactionCostView: View {
    
    @Bindable var accountVM: AccountViewModel
    @Bindable var transactionVM: TransactionVM
    
    @State private var amount: String = ""
    @State private var transactionDate: Date = Date()
    @State private var note: String = ""
    
    
    var body: some View {
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
            Form {
                Section("Account") {
                    Picker("", selection: $accountVM.accounts) {
                        ForEach(accountVM.accounts) { account in
                            HStack {
                                Text(account.name)
                                Spacer()
                                Text("\(account.balance) \(account.currencyRaw)")
                                    .foregroundColor(.secondary)
                            }
                            .tag(account as Account?) //?
                        }
                    }
                    .pickerStyle(.automatic)
                }
                
                Section("Amount") {
                    TextField("", text: $amount)
                        .keyboardType(.decimalPad)
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
                    //  Button(action: /*saveTransaction*/) {
                    HStack {
                        Spacer()
                        Text("Save Transaction")
                            .bold()
                        Spacer()
                    }
                }
                
            }
        }
    }
}
    
    
    #Preview {
        TransactionCostView(accountVM: AccountViewModel())
    }

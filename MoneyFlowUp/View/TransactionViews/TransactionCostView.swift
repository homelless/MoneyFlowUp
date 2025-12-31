//
//  TransactionCostView.swift
//  MoneyFlow
//
//  Created by MacBookAir on 31.12.25.
//

import SwiftUI

struct TransactionCostView: View {
    
    @Bindable var accountVM: AccountViewModel
    
    
    var body: some View {
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
            Form {
                Section("Account") {
                    Picker("Select account", selection: $accountVM.accounts) {
                        ForEach(accountVM.accounts) { account in
                            
                        }
                    }
                }
            }
            
        }
    }
}



#Preview {
    TransactionCostView(accountVM: AccountViewModel())
}

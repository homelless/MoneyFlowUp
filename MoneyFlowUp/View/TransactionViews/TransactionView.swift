//
//  TransactionView.swift
//  MoneyFlow
//
//  Created by MacBookAir on 30.12.25.
//

import SwiftUI

struct TransactionView: View {
    
    @State var selectionPicker = 0
    
    let selectionItems : [String] = [
        "income",
        "cost",
        "transfer"
    ]
    
    
    
    var body: some View {
        
        ZStack {
            
            TabView {
                Tab("cost", systemImage: "cart.badge.plus") { TransactionCostView(accountVM: AccountViewModel()) }
                Tab("income", systemImage: "dollarsign.ring.dashed") { TransactionIncomeView() }
                Tab("transfer", systemImage: "arrow.triangle.2.circlepath") { TransactionTransferView() }
                Tab("transactions", systemImage: "list.bullet.rectangle"){ TransactionsListView() }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
        }
    }
}

#Preview {
    TransactionView()
}

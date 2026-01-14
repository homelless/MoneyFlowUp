

import SwiftUI

struct TransactionView: View {
    
    @Bindable private var transactionVM = TransactionVM()
    @Bindable private var accountVM = AccountViewModel()

    
    
    var body: some View {
        
        ZStack {
            
            TabView() {
                Tab("cost", systemImage: "cart.badge.plus") {
                    TransactionCostView(accountVM: accountVM, transactionVM: transactionVM) }
                
                Tab("income", systemImage: "dollarsign.ring.dashed") {
                    TransactionIncomeView(accountVM: accountVM, transactionVM: transactionVM) }
                
                Tab("transfer", systemImage: "arrow.triangle.2.circlepath") {
                    TransactionTransferView(accountVM: accountVM, transactionVM: transactionVM) }
                
                Tab("transactions", systemImage: "list.bullet.rectangle") {
                    TransactionsListView(transactionVM: transactionVM) }
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

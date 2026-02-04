

import SwiftUI

struct TransactionView: View {
    
    @Bindable  var transactionVM : TransactionVM
    @Bindable  var accountVM : AccountViewModel
    @Binding var path: [Route]
    
    
    var body: some View {
        
        ZStack {
            
            TabView() {
                Tab("Траты", systemImage: "cart.badge.plus") {
                    TransactionCostView(accountVM: accountVM, transactionVM: transactionVM) }
                
                Tab("Заработок", systemImage: "dollarsign.ring.dashed") {
                    TransactionIncomeView(accountVM: accountVM, transactionVM: transactionVM) }
                
                Tab("Перевод", systemImage: "arrow.triangle.2.circlepath") {
                    TransactionTransferView(accountVM: accountVM, transactionVM: transactionVM) }
                
                Tab("Транзакции", systemImage: "list.bullet.rectangle") {
                    TransactionsListView(transactionVM: transactionVM, accountVM: accountVM, path: $path) }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
        }
    }
}


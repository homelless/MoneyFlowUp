

import SwiftUI

struct TransactionView: View {
    
    @Bindable  var transactionVM : TransactionVM
    @Bindable  var accountVM : AccountViewModel

    
    
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
                    TransactionsListView(transactionVM: transactionVM) }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
        }
    }
}

#Preview {
    TransactionView(transactionVM: TransactionVM(), accountVM: AccountViewModel())
}

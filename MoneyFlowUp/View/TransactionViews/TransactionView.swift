import SwiftUI

// Контейнер для вкладок работы с транзакциями.
// Содержит три вкладки для создания (Траты/Заработок/Перевод) и вкладку списка транзакций.
struct TransactionView: View {
    
    // ViewModel'ы, пробрасываемые во вложенные экраны
    @Bindable  var transactionVM : TransactionVM
    @Bindable  var accountVM : AccountViewModel
    // Путь навигации (NavigationStack)
    @Binding var path: [Route]
    
    var body: some View {
        ZStack {
            // Вкладки с разными сценариями работы с транзакциями
            TabView() {
                Tab("Траты", systemImage: "cart.badge.plus") {
                    TransactionCostView(accountVM: accountVM, transactionVM: transactionVM)
                }
                
                Tab("Заработок", systemImage: "dollarsign.ring.dashed") {
                    TransactionIncomeView(accountVM: accountVM, transactionVM: transactionVM)
                }
                
                Tab("Перевод", systemImage: "arrow.triangle.2.circlepath") {
                    TransactionTransferView(accountVM: accountVM, transactionVM: transactionVM)
                }
                
                Tab("Транзакции", systemImage: "list.bullet.rectangle") {
                    TransactionsListView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
                }
            }
            .tint(Color("текст"))
            // Дополнительный отступ под таббар/кнопки снизу, чтобы контент не перекрывался
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
            }
        }
    }
}


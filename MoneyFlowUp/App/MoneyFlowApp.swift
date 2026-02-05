
import SwiftUI
import SwiftData

@main
struct MoneyFlowUpApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Account.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup { RootView(accountVM: AccountViewModel(), transactionVM: TransactionVM()) }
            .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Bindable var accountVM: AccountViewModel
    @Bindable var transactionVM: TransactionVM
    @State private var path = [Route]()
    @State var selectedTab : Bool = false
    @State var accounts: [Account] = []
    
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                TabView {
                    Tab("Кошельки", systemImage: "wallet.bifold.fill") {
                        AccountListView(accountVM: accountVM , transactionVM: transactionVM, path: $path)
                    }
                    Tab("Транзакции", systemImage: "pencil.and.outline") {
                        TransactionsListView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
                    }
                    Tab("Бюджет", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90") { }
                    Tab("Отчеты", systemImage: "document.on.document") { }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 100)
                }
            }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .addAccount:
                        AccountAddView(viewModel: accountVM)
                    case .detail(let accountID):
                        if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                            AccountDetailView(account: account, accountVM: accountVM)
                        } else {
                            Text("Кошелек не найден")
                        }
                    case .addTransaction:
                        TransactionView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
                    }
                }
        }
    }
}

#Preview {
    RootView(accountVM: AccountViewModel(), transactionVM: TransactionVM())
}

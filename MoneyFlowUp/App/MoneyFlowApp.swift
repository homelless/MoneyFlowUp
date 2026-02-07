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
        WindowGroup { RootView() }
            .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var accountVM: AccountViewModel?
    @State private var transactionVM: TransactionVM?
    @State private var path = [Route]()

    var body: some View {
        Group {
            if let accountVM, let transactionVM {
                NavigationStack(path: $path) {
                    ZStack {
                        TabView {
                            Tab("Кошельки", systemImage: "wallet.bifold.fill") {
                                AccountListView(accountVM: accountVM, transactionVM: transactionVM, path: $path)
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
                        case .calendar(let date):
                            TransactionsCalendarView(selectedDate: date, transactionVM: transactionVM, accountVM: accountVM)
                        }
                    }
                }
            } else {
                ProgressView()
                    .onAppear {
                        accountVM = AccountViewModel(context: modelContext)
                        transactionVM = TransactionVM(context: modelContext)
                    }
            }
        }
    }
}

#Preview { RootView() }

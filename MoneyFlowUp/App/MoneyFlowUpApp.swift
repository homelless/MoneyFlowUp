/*
 
 
 
 
 
 
 "MoneyFlowUp - это простое и наглядное приложение для учета личных финансов. Добавляйте доходы и расходы, переводите средства между кошельками, анализируйте структуру трат по категориям и следите за динамикой."
 
 
 Технологии: SwiftUI / SwiftData / MVVM / Observation / GCD
 
 
 
*/
import SwiftUI
import SwiftData
import UIKit



@main
struct MoneyFlowUpApp: App {
    // Общий контейнер моделей 
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Account.self,
            CustomCostCategory.self,
            CustomIncomeCategory.self,
            HiddenCategory.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @State private var showWelcome = true
    

    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(named: "фон") // или ваш цвет в hex/RGB

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(named: "текст") // цвет кнопок

        // Если хотите изменить цвет текста заголовка
        appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "текст") ?? .black]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(named: "текст") ?? .black]
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if showWelcome {
                    WelcomeView {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showWelcome = false
                        }
                    }
                } else {
                    RootView()
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}

// Корневой экран приложения.
// Создает и хранит ViewModel'ы (AccountViewModel и TransactionVM), затем строит TabView с навигацией.
struct RootView: View {
    
    @Environment(\.modelContext) private var modelContext
    @State private var accountVM: AccountViewModel?
    @State private var transactionVM: TransactionVM?
    @State private var path = [Route]()
    // Сторы теперь требуют контекст — создадим их после появления modelContext
    @State private var costCategoriesStore: CategoriesStore<CostCategory>?
    @State private var incomeCategoriesStore: CategoriesStore<IncomeCategory>?

    var body: some View {
        Group {
            if let accountVM, let transactionVM, let costCategoriesStore, let incomeCategoriesStore {
                NavigationStack(path: $path) {
                    ZStack {
                        TabView {
                            Tab("Кошельки", systemImage: "wallet.bifold.fill") {
                                AccountListView(accountVM: accountVM, transactionVM: transactionVM, path: $path)
                            }
                            Tab("Транзакции", systemImage: "pencil.and.outline") {
                                TransactionsListView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
                            }
                            Tab("Бюджет", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90") {
                                ReportsView(transactionVM: transactionVM)
                            }
                            Tab("Настройки", systemImage: "gear") {
                                SettingView(transactionVM: transactionVM)
                            }
                        }
                        .tint(Color("текст"))
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
                            TransactionsCalendarView(selectedDate: date, transactionVM: transactionVM, accountVM: accountVM,path: $path)
                        case .accountTransactions(let accountID):
                            if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                                AccountTransactionsView(transactionVM: transactionVM, accountVM: accountVM, path: $path, accountID: accountID)
                            } else {
                                Text("Кошелек не найден")
                            }
                        case .transactionsDetail(let txID):
                            if let tx = transactionVM.transactions.first(where: { $0.id == txID }) {
                                TransactionDetailView(accountVM: accountVM, transactionVM: transactionVM, editingTransaction: tx)
                            } else {
                                Text("Транзакция не найдена")
                            }
                        }
                    }
                }
                // Кладем сторы в окружение
                .environment(costCategoriesStore)
                .environment(incomeCategoriesStore)
            } else {
                // Инициализация VM и Store при первом появлении
                ProgressView()
                    .onAppear {
                        accountVM = AccountViewModel(context: modelContext)
                        transactionVM = TransactionVM(context: modelContext)
                        // Инициализируем сторы из SwiftData
                        costCategoriesStore = CategoriesStore<CostCategory>(
                            context: modelContext,
                            presets: CostCategory.all,
                            makeItem: { name, icon in
                                CostCategory(id: "cost_custom_\(UUID().uuidString)", name: name, icon: icon, color: .black)
                            }
                        )
                        incomeCategoriesStore = CategoriesStore<IncomeCategory>(
                            context: modelContext,
                            presets: IncomeCategory.all,
                            makeItem: { name, icon in
                                IncomeCategory(id: "income_custom_\(UUID().uuidString)", name: name, icon: icon, color: .black)
                            }
                        )
                    
                        // Регистрируем общедоступные ссылки на сторы
                        CategoriesStores.sharedCost = costCategoriesStore
                        CategoriesStores.sharedIncome = incomeCategoriesStore
                    }
            }
        }
    }
}

#Preview { RootView() }


import SwiftUI
import SwiftData

@main
struct MoneyFlowUpApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Transaction.self,
            Account.self,
            CategoryTransaction.self,
            
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup { RootView(viewModel: AccountViewModel()) }
         .modelContainer(sharedModelContainer)
    }
}

struct RootView: View {
    @Bindable var viewModel: AccountViewModel
    @State private var path = [Route]()
    @State var selectedTab : Bool = false
    @State var accounts: [Account] = []
 

    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                TabView {
                    Tab("Wallet", systemImage: "wallet.bifold.fill") {
                        AccountListView(viewModel: viewModel, path: $path)
                    }
                    Tab("Cost", systemImage: "pencil.and.outline") { }
                    Tab("Budget", systemImage: "dollarsign.arrow.trianglehead.counterclockwise.rotate.90") { }
                    Tab("Reports", systemImage: "document.on.document") { }
                }
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 100)
                }

                GeometryReader { geo in
                    VStack {
                        Spacer()
                        Button(action: {
                            path.append(.addTransaction)
                        }) {
                            Text("add transaction")
                                .foregroundColor(.black)
                                .frame(width: 360, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color("addColor")).opacity(0.9)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .contentShape(RoundedRectangle(cornerRadius: 20))
                        .zIndex(1)
                        .padding(.bottom, geo.safeAreaInsets.bottom + 100)
                    }
                    .frame(width: geo.size.width, height: geo.size.height, alignment: .bottom)
                }
                .ignoresSafeArea()
            }
            // здесь описываем переходы
            .navigationDestination(for: Route.self) { route in
                                switch route {
                                case .add:
                                    AccountAddView(viewModel: viewModel)
                                case .detail(let account):
                                    AccountDetailView(account: account)
                                case .addTransaction:
                                    TransactionView() 
                                }
                            }
        }
    }
}

#Preview {
    RootView(viewModel: AccountViewModel())
}

import SwiftUI
import SwiftData

struct SettingView: View {
    
    @Bindable var transactionVM: TransactionVM
    
    
    var body: some View {
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
        
            VStack {
                List {
            
                    Section("Настройки"){
                        NavigationLink("О программе", destination: AboutAppView())
                        NavigationLink("Категории трат", destination: SettingCostCategoriesView())
                        NavigationLink("Категории доходов", destination: SettingIncomeCategoriesView())
                        
                    }
                    .listRowBackground(Color("addColor"))
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
            }
        }
    }
}

#Preview {

    let schema = Schema([
        Transaction.self,
        Account.self
    ])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    let context = ModelContext(container)
    
    let txVM = TransactionVM(context: context)
    
    return SettingView(transactionVM: txVM)
}

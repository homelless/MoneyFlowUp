import SwiftUI
import SwiftData

struct SettingView: View {
    
    @Bindable var transactionVM: TransactionVM
    
    
    var body: some View {
        ZStack {
            Color("фон")
                .ignoresSafeArea()
            
        
            VStack {
                List {
            
                    Section(""){
                        NavigationLink("О программе", destination: AboutAppView())
                        NavigationLink("Категории трат", destination: SettingCostCategoriesView())
                        NavigationLink("Категории доходов", destination: SettingIncomeCategoriesView())
                        
                    }
                    .foregroundStyle(Color("текст"))
                    .listRowBackground(Color("ячейка"))
                }
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
            }
        }
    }
}

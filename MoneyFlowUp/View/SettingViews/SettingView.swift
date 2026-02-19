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

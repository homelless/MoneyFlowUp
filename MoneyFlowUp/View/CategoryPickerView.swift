
import SwiftUI
import Foundation


struct CategoryPickerView<CategoryType: TransactionTypeProtocol>: View {
    @Binding var selectedCategory: CategoryType
    let categories: [CategoryType]
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List(categories) { category in
                Button(action: {
                    selectedCategory = category
                    dismiss()
                }) {
                    HStack {
                        Image(systemName: category.icon)
                            .frame(width: 30)
                        
                        Text(category.name)
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        if category.id == selectedCategory.id {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}



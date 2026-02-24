import SwiftUI
import Foundation

// Универсальный экран выбора категории (generic).
// Работает с любым типом, соответствующим TransactionTypeProtocol.
// Отображает список категорий, позволяет выбрать одну и закрыть экран.
struct CategoryPickerView<CategoryType: TransactionTypeProtocol>: View {
    // Текущая выбранная категория (двусторонняя привязка)
    @Binding var selectedCategory: CategoryType
    // Список доступных категорий
    let categories: [CategoryType]
    // Заголовок экрана
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("фон")
                    .ignoresSafeArea()
                
                List(categories) { category in
                    Button(action: {
                        // Устанавливаем выбранную категорию и закрываем экран
                        selectedCategory = category
                        dismiss()
                    }) {
                        HStack {
                            
                            Image(systemName: category.icon)
                                .frame(width: 30)
                            
                            Text(category.name)
                                .foregroundColor(.текст)
                            
                            Spacer()
                            
                            // Галочка у выбранной категории
                            if category.id == selectedCategory.id {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                }
                
                .scrollContentBackground(.hidden)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    // Альтернативная кнопка закрытия
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Готово") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}


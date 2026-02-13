import SwiftUI
import Observation

struct SettingCostCategoriesView: View {
    // Единый стор категорий трат из окружения
    @Environment(CategoriesStore<CostCategory>.self) private var store
    
    @State private var isPresentingAdd = false
    @State private var newName = ""
    @State private var newIcon = ""
    
    var body: some View {
        List {
            Section("Категории трат") {
                ForEach(store.categories) { category in
                    HStack(spacing: 12) {
                        Image(systemName: category.icon)
                            .foregroundStyle(category.color)
                        Text(category.name)
                        Spacer()
                    }
                }
                // Удаляем только кастомные категории трат
                .onDelete(perform: handleDelete)
            }
        }
        .navigationTitle("Категории трат")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingAdd = true
                    newName = ""
                    newIcon = ""
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $isPresentingAdd) {
            NavigationStack {
                Form {
                    Section("Новая категория траты") {
                        TextField("Название", text: $newName)
                        TextField("Иконка (SF Symbol)", text: $newIcon)
                    }
                }
                .navigationTitle("Добавить")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Отмена") { isPresentingAdd = false }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Сохранить") {
                            store.add(name: newName, icon: newIcon)
                            isPresentingAdd = false
                        }
                        .disabled(newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    private func handleDelete(_ offsets: IndexSet) {
        let items = store.categories
        for index in offsets {
            guard items.indices.contains(index) else { continue }
            let item = items[index]
            store.deleteByID(item.id) // теперь удаляем пресеты (скрытие) и кастомные (физически)
        }
    }
}

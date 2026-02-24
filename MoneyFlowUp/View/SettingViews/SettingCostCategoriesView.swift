import SwiftUI
import Observation

struct SettingCostCategoriesView: View {
    // Единый стор категорий трат из окружения
    @Environment(CategoriesStore<CostCategory>.self) private var store
    
    @State private var isPresentingAdd = false
    @State private var newName = ""
    @State private var newIcon = ""
    let costCategoryIcons = [
        "fork.knife",           // еда
        "cart",                 // покупки
        "car",                  // транспорт
        "tram",                 // городской транспорт
        "bicycle",              // велосипед
        "fuelpump",             // топливо
        "house",                // жильё, аренда
        "wrench.and.screwdriver", // ремонт
        "bolt",                 // коммуналка, электроэнергия
        "doc.text",             // счета
        "film",                 // развлечения
        "gamecontroller",       // игры
        "music.note",           // музыка
        "pawprint",             // питомцы
        "gift",                 // подарки
        "bed.double",           // отели, ночёвка
        "tshirt",               // одежда
        "scissors",             // парикмахерская
        "leaf",                 // экология, растения
        "heart",                // здоровье
        "stethoscope",          // медицина
        "airplane",             // путешествия
        "graduationcap",        // образование
        "hammer",               // услуги, работа
        "creditcard",           // финансы, кредиты
        "shippingbox",          // посылки, доставка
        "trash",                // мусор, сортировка
        "cart.badge.plus",      // крупные покупки
        "cup.and.saucer",       // кафе, кофе
    ]
    
    var body: some View {
        
        ZStack {
            Color("фон")
                .ignoresSafeArea()
            
            List {
                Section("") {
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
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
            }
            .scrollContentBackground(.hidden)
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
                    ZStack(alignment: .top) {
                    Form {
                        Section("Новая категория траты") {
                            TextField("Название", text: $newName)
                            Picker("Иконка", selection: $newIcon) {
                                ForEach(costCategoryIcons, id: \.self) { icon in
                                    VStack {
                                        Image(systemName: icon)
                                            .tint(.black)
                                    }
                                    .tag(icon)
                                }
                          
                            }
                        }
                            .listRowBackground(Color("ячейка"))
                        }
                        .background(Color("фон"))
                        .scrollContentBackground(.hidden)
                    }
                    .foregroundStyle(Color("текст"))
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
                    // Цвет кнопок тулбара
                    .tint(Color("текст"))
                    .toolbarBackground(Color("фон"), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .background(Color("фон").ignoresSafeArea())
                }
                .presentationDetents([.medium])
            }
        }
    }
    
    private func handleDelete(_ offsets: IndexSet) {
        let items = store.categories
        for index in offsets {
            guard items.indices.contains(index) else { continue }
            let item = items[index]
            store.deleteByID(item.id)
        }
    }
}

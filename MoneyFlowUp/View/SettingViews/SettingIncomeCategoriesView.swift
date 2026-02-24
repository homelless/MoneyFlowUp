import SwiftUI
import Observation

struct SettingIncomeCategoriesView: View {
    // Получаем единый стор доходных категорий из окружения
    @Environment(CategoriesStore<IncomeCategory>.self) private var store
    
    @State private var isPresentingAdd = false
    @State private var newName = ""
    @State private var newIcon = ""
    let incomeCategoryIcons = [
        "dollarsign.circle",    // основная работа
        "creditcard",           // карта, выплаты
        "building.columns",     // зарплата, компания
        "gift",                 // подарок
        "briefcase",            // бизнес
        "star",                 // премия
        "graduationcap",        // стипендия
        "sparkles",             // подработка
        "arrow.up.right.circle",// проценты, инвестиции
        "banknote",             // наличные
        "person.2.wave.2",      // перевод
        "cart",                 // продажа
        "leaf",                 // кэшбэк, эко-бонусы
        "chart.line.uptrend.xyaxis", // рост, ценные бумаги
        "plus.circle",          // другое поступление
        "app.badge",            // IT, цифровой доход
        "music.mic",            // творчество
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
                    // Удаляем только кастомные категории, пресеты пропускаем
                    .onDelete(perform: handleDelete)
                }
                .listRowBackground(Color("ячейка"))
                .foregroundStyle(Color("текст"))
            }
            .scrollContentBackground(.hidden)
            .navigationTitle("Категории доходов")
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
                    ZStack {
                        Color("фон")
                        Form {
                            Section("Новая категория дохода") {
                                TextField("Название", text: $newName)
                                Picker("Иконка", selection: $newIcon) {
                                    ForEach(incomeCategoryIcons, id: \.self) { icon in
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
                    // Применяем стиль к контенту, не к навбара
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
                    .tint(Color("текст"))
                    .toolbarBackground(Color("фон"), for: .navigationBar)
                    .toolbarBackground(.visible, for: .navigationBar)
                    .background(Color("фон").ignoresSafeArea())
                }
                // Убираем внешнее .background — оно не нужно и может мешать
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

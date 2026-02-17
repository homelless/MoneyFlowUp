import SwiftUI
import Observation
import SwiftData

@Observable
final class CategoriesStore<T: TransactionTypeProtocol> { // Дженерик-хранилище категорий для типа T (расход/доход)
    private(set) var categories: [T]
    
    private let makeItem: ((String, String) -> T)?        // Фабрика для создания T по (name, icon) для добавления
    private let modelContext: ModelContext
    private let presets: [T]                              // Предустановленные категории (не в БД)
    
    init(context: ModelContext, presets: [T], makeItem: ((String, String) -> T)? = nil) {
        self.modelContext = context
        self.presets = presets
        self.makeItem = makeItem
        self.categories = []              // Изначально пусто
        reloadFromStorage()               // Загружаем из БД: скрытые пресеты и кастомные
    }

    func add(_ item: T) {
        persistIfCustom(item)             // Если это кастомная категория — сохранить в БД
        reloadFromStorage()               // Пересобрать список с учетом БД и пресетов
    }

    func add(name: String, icon: String) {
        guard let makeItem else { return }                      // Если фабрики нет — ничего не делаем
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let iconName = icon.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeIcon = iconName.isEmpty ? "tag" : iconName
        let newItem = makeItem(trimmedName, safeIcon)
        persistIfCustom(newItem)                                 // Если кастомный — сохраняем в БД
        reloadFromStorage()                                      // Обновляем отображаемый список
    }

    func delete(at offsets: IndexSet) {
        let items = categories
        for index in offsets {                 // Для каждого индекса из UI (List .onDelete)
            guard items.indices.contains(index) else { continue } // Защита от выхода за границы
            let item = items[index]
            deleteByID(item.id)
        }
        reloadFromStorage()                    // Перечитываем состояние
    }
    
    func deleteByID(_ id: String) {
        if isCustomID(id) {          // Если это кастомная категория…
            deleteCustomByID(id)     // …удаляем запись из БД
        } else {
            hidePreset(id: id)       // Иначе это пресет — помечаем как скрытый в БД
        }
        reloadFromStorage()          // Обновляем список категорий
    }
    
    func unhidePreset(id: String) {
        // Ищем запись HiddenCategory с таким id, чтобы снова показать пресет
        let descriptor = FetchDescriptor<HiddenCategory>(predicate: #Predicate { $0.id == id })
        if let hidden = try? modelContext.fetch(descriptor).first { // Если скрытая запись найдена
            modelContext.delete(hidden)          // Удаляем "скрытие"
            try? modelContext.save()             // Сохраняем изменения
        }
        reloadFromStorage()                      // Перечитываем список
    }
    
    @discardableResult
    func update(id: String, newName: String? = nil, newIcon: String? = nil) -> Bool {
        guard isCustomID(id) else { return false } // Изменять можно только кастомные категории
        
        if T.self == CostCategory.self { // Ветка для кастомных расходов
            let descriptor = FetchDescriptor<CustomCostCategory>(predicate: #Predicate { $0.id == id })
            guard let model = try? modelContext.fetch(descriptor).first else { return false } // Находим модель
            if let newName {
                let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines) // Тримим имя
                if !trimmed.isEmpty { model.name = trimmed }                           // Обновляем, если не пусто
            }
            if let newIcon {
                let trimmedIcon = newIcon.trimmingCharacters(in: .whitespacesAndNewlines) // Тримим иконку
                model.icon = trimmedIcon.isEmpty ? "tag" : trimmedIcon                    // Дефолт "tag", если пусто
            }
            do {
                try modelContext.save()     // Сохраняем изменения в БД
                reloadFromStorage()         // Обновляем список
                return true                 // Успех
            } catch {
                return false                // Ошибка сохранения
            }
        } else if T.self == IncomeCategory.self { // Ветка для кастомных доходов
            let descriptor = FetchDescriptor<CustomIncomeCategory>(predicate: #Predicate { $0.id == id })
            guard let model = try? modelContext.fetch(descriptor).first else { return false } // Находим модель
            if let newName {
                let trimmed = newName.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty { model.name = trimmed }
            }
            if let newIcon {
                let trimmedIcon = newIcon.trimmingCharacters(in: .whitespacesAndNewlines)
                model.icon = trimmedIcon.isEmpty ? "tag" : trimmedIcon
            }
            do {
                try modelContext.save()
                reloadFromStorage()
                return true
            } catch {
                return false
            }
        }
        return false // Если тип T иной (не ожидается) — обновление не поддерживается
    }
    
    @discardableResult
    func updateName(id: String, to newName: String) -> Bool {
        update(id: id, newName: newName, newIcon: nil) // Удобный шорткат для смены имени
    }
    
    @discardableResult
    func updateIcon(id: String, to newIcon: String) -> Bool {
        update(id: id, newName: nil, newIcon: newIcon) // Удобный шорткат для смены иконки
    }
    
    func reload() {
        reloadFromStorage() // Публичный метод перезагрузки (например, по кнопке)
    }
}

private extension CategoriesStore {
    func reloadFromStorage() {
        // Собираем множество скрытых пресетов из БД (HiddenCategory)
        let hiddenPresetIDs: Set<String> = {
            let descriptor = FetchDescriptor<HiddenCategory>()               // Запрос всех HiddenCategory
            let hidden = (try? modelContext.fetch(descriptor)) ?? []         // Читаем, либо пустой массив
            return Set(hidden.map { $0.id })                                 // Множество скрытых id
        }()
        
        // Получаем кастомные категории из БД (разные модели для расходов/доходов) и приводим к T
        let customAsT: [T] = fetchCustom().compactMap { mapToT($0) }
        // Фильтруем пресеты: исключаем те, что скрыты
        let visiblePresets = presets.filter { !hiddenPresetIDs.contains($0.id) }
        // Объединяем видимые пресеты и кастомные из БД
        categories = visiblePresets + customAsT
    }
    
    func fetchCustom() -> [Any] {
        // Для типа расходов читаем CustomCostCategory
        if T.self == CostCategory.self {
            let descriptor = FetchDescriptor<CustomCostCategory>()
            let items = (try? modelContext.fetch(descriptor)) ?? []  // Все кастомные расходы
            return items
        // Для типа доходов читаем CustomIncomeCategory
        } else if T.self == IncomeCategory.self {
            let descriptor = FetchDescriptor<CustomIncomeCategory>()
            let items = (try? modelContext.fetch(descriptor)) ?? []  // Все кастомные доходы
            return items
        } else {
            return [] // Для иных T кастомных моделей не предусмотрено
        }
    }
    
    func mapToT(_ anyItem: Any) -> T? {
        // Преобразуем модель БД кастомной траты к публичной модели CostCategory (цвет задаем дефолтно .black)
        if let c = anyItem as? CustomCostCategory, T.self == CostCategory.self {
            let mapped = CostCategory(id: c.id, name: c.name, icon: c.icon, color: .black)
            return mapped as? T
        }
        // Аналогично для доходов
        if let c = anyItem as? CustomIncomeCategory, T.self == IncomeCategory.self {
            let mapped = IncomeCategory(id: c.id, name: c.name, icon: c.icon, color: .black)
            return mapped as? T
        }
        return nil // Если тип не совпадает — вернуть nil
    }
    
    func persistIfCustom(_ item: T) {
        let id = item.id
        // Если это расходная категория и id имеет префикс кастомной — сохраняем в БД как CustomCostCategory
        if T.self == CostCategory.self, id.hasPrefix("cost_custom_") {
            let model = CustomCostCategory(id: id, name: item.name, icon: item.icon)
            modelContext.insert(model)
            try? modelContext.save()
        // Если доходная и id с префиксом кастомной — сохраняем как CustomIncomeCategory
        } else if T.self == IncomeCategory.self, id.hasPrefix("income_custom_") {
            let model = CustomIncomeCategory(id: id, name: item.name, icon: item.icon)
            modelContext.insert(model)
            try? modelContext.save()
        }
    }
    
    func isCustomID(_ id: String) -> Bool {
        // Правило определения кастомности по префиксу id
        if T.self == CostCategory.self { return id.hasPrefix("cost_custom_") }
        if T.self == IncomeCategory.self { return id.hasPrefix("income_custom_") }
        return false
    }
    
    func deleteCustomByID(_ id: String) {
        // Удаляем запись кастомной расходной категории из БД
        if T.self == CostCategory.self {
            let descriptor = FetchDescriptor<CustomCostCategory>(predicate: #Predicate { $0.id == id })
            if let toDelete = try? modelContext.fetch(descriptor).first {
                modelContext.delete(toDelete)
                try? modelContext.save()
            }
        // Удаляем запись кастомной доходной категории из БД
        } else if T.self == IncomeCategory.self {
            let descriptor = FetchDescriptor<CustomIncomeCategory>(predicate: #Predicate { $0.id == id })
            if let toDelete = try? modelContext.fetch(descriptor).first {
                modelContext.delete(toDelete)
                try? modelContext.save()
            }
        }
    }
    
    func hidePreset(id: String) {
        // Если пресет уже скрыт — выходим
        let descriptor = FetchDescriptor<HiddenCategory>(predicate: #Predicate { $0.id == id })
        if let existing = try? modelContext.fetch(descriptor).first, existing != nil {
            return
        }
        // Иначе создаем запись HiddenCategory с этим id, чтобы скрыть пресет
        let hidden = HiddenCategory(id: id)
        modelContext.insert(hidden)
        try? modelContext.save()
    }
}


enum CategoriesStores {
    // Глобальные (одиночные) хранилища для удобного доступа по всему приложению
    static var sharedCost: CategoriesStore<CostCategory>?
    static var sharedIncome: CategoriesStore<IncomeCategory>?
}

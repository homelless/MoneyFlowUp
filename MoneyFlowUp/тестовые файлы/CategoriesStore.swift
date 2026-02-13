import SwiftUI
import Observation
import SwiftData

@Observable
final class CategoriesStore<T: TransactionTypeProtocol> {
    private(set) var categories: [T]
    
    private let makeItem: ((String, String) -> T)?
    private let modelContext: ModelContext
    private let presets: [T]
    
    init(context: ModelContext, presets: [T], makeItem: ((String, String) -> T)? = nil) {
        self.modelContext = context
        self.presets = presets
        self.makeItem = makeItem
        self.categories = []
        reloadFromStorage()
    }


    func add(_ item: T) {
        persistIfCustom(item)
        reloadFromStorage()
    }

    func add(name: String, icon: String) {
        guard let makeItem else { return }
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }
        let iconName = icon.trimmingCharacters(in: .whitespacesAndNewlines)
        let safeIcon = iconName.isEmpty ? "tag" : iconName
        let newItem = makeItem(trimmedName, safeIcon)
        persistIfCustom(newItem)
        reloadFromStorage()
    }


    func delete(at offsets: IndexSet) {
        let items = categories
        for index in offsets {
            guard items.indices.contains(index) else { continue }
            let item = items[index]
            deleteByID(item.id)
        }
        reloadFromStorage()
    }
    
    func deleteByID(_ id: String) {
        if isCustomID(id) {
           
            deleteCustomByID(id)
        } else {
  
            hidePreset(id: id)
        }
        reloadFromStorage()
    }
    

    func unhidePreset(id: String) {
        let descriptor = FetchDescriptor<HiddenCategory>(predicate: #Predicate { $0.id == id })
        if let hidden = try? modelContext.fetch(descriptor).first {
            modelContext.delete(hidden)
            try? modelContext.save()
        }
        reloadFromStorage()
    }
    
 
    @discardableResult
    func update(id: String, newName: String? = nil, newIcon: String? = nil) -> Bool {
        guard isCustomID(id) else { return false }
        
        if T.self == CostCategory.self {
            let descriptor = FetchDescriptor<CustomCostCategory>(predicate: #Predicate { $0.id == id })
            guard let model = try? modelContext.fetch(descriptor).first else { return false }
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
        } else if T.self == IncomeCategory.self {
            let descriptor = FetchDescriptor<CustomIncomeCategory>(predicate: #Predicate { $0.id == id })
            guard let model = try? modelContext.fetch(descriptor).first else { return false }
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
        return false
    }
    
    @discardableResult
    func updateName(id: String, to newName: String) -> Bool {
        update(id: id, newName: newName, newIcon: nil)
    }
    
    @discardableResult
    func updateIcon(id: String, to newIcon: String) -> Bool {
        update(id: id, newName: nil, newIcon: newIcon)
    }
    

    func reload() {
        reloadFromStorage()
    }
}


private extension CategoriesStore {
    func reloadFromStorage() {
      
        let hiddenPresetIDs: Set<String> = {
            let descriptor = FetchDescriptor<HiddenCategory>()
            let hidden = (try? modelContext.fetch(descriptor)) ?? []
            return Set(hidden.map { $0.id })
        }()
        
      
        let customAsT: [T] = fetchCustom().compactMap { mapToT($0) }
        
     
        let visiblePresets = presets.filter { !hiddenPresetIDs.contains($0.id) }
        
      
        categories = visiblePresets + customAsT
    }
    
    func fetchCustom() -> [Any] {
        if T.self == CostCategory.self {
            let descriptor = FetchDescriptor<CustomCostCategory>()
            let items = (try? modelContext.fetch(descriptor)) ?? []
            return items
        } else if T.self == IncomeCategory.self {
            let descriptor = FetchDescriptor<CustomIncomeCategory>()
            let items = (try? modelContext.fetch(descriptor)) ?? []
            return items
        } else {
            return []
        }
    }
    
    func mapToT(_ anyItem: Any) -> T? {
        if let c = anyItem as? CustomCostCategory, T.self == CostCategory.self {
            let mapped = CostCategory(id: c.id, name: c.name, icon: c.icon, color: .black)
            return mapped as? T
        }
        if let c = anyItem as? CustomIncomeCategory, T.self == IncomeCategory.self {
            let mapped = IncomeCategory(id: c.id, name: c.name, icon: c.icon, color: .black)
            return mapped as? T
        }
        return nil
    }
    
    func persistIfCustom(_ item: T) {
        let id = item.id
        if T.self == CostCategory.self, id.hasPrefix("cost_custom_") {
            let model = CustomCostCategory(id: id, name: item.name, icon: item.icon)
            modelContext.insert(model)
            try? modelContext.save()
        } else if T.self == IncomeCategory.self, id.hasPrefix("income_custom_") {
            let model = CustomIncomeCategory(id: id, name: item.name, icon: item.icon)
            modelContext.insert(model)
            try? modelContext.save()
        }
    }
    
    func isCustomID(_ id: String) -> Bool {
        if T.self == CostCategory.self { return id.hasPrefix("cost_custom_") }
        if T.self == IncomeCategory.self { return id.hasPrefix("income_custom_") }
        return false
    }
    
    func deleteCustomByID(_ id: String) {
        if T.self == CostCategory.self {
            let descriptor = FetchDescriptor<CustomCostCategory>(predicate: #Predicate { $0.id == id })
            if let toDelete = try? modelContext.fetch(descriptor).first {
                modelContext.delete(toDelete)
                try? modelContext.save()
            }
        } else if T.self == IncomeCategory.self {
            let descriptor = FetchDescriptor<CustomIncomeCategory>(predicate: #Predicate { $0.id == id })
            if let toDelete = try? modelContext.fetch(descriptor).first {
                modelContext.delete(toDelete)
                try? modelContext.save()
            }
        }
    }
    
    func hidePreset(id: String) {
       
        let descriptor = FetchDescriptor<HiddenCategory>(predicate: #Predicate { $0.id == id })
        if let existing = try? modelContext.fetch(descriptor).first, existing != nil {
            return
        }
        let hidden = HiddenCategory(id: id)
        modelContext.insert(hidden)
        try? modelContext.save()
    }
}

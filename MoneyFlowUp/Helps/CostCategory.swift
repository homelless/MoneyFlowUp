
import SwiftUI
import Foundation

// Модель категории для транзакций типа "Трата".
// Реализует TransactionTypeProtocol, чтобы единообразно работать с категориями (id, name, icon, group).
// Используется в UI для отображения списка категорий, фильтрации и выбора иконок/названий.
struct CostCategory: TransactionTypeProtocol {
    
    // Уникальный идентификатор категории (например, для Identifiable/Hashable и хранения)
    var id: String
    // Локализованное название категории, отображается в интерфейсе
    let name: String
    // Имя системной SF Symbol иконки для визуального представления
    let icon: String
    
    // Группа транзакций: фиксировано .cost (траты)
    var group: TransactionGroup { .cost }
    
    // Предустановленные категории трат (для быстрого выбора пользователем)
    static let food = CostCategory(id: "cost_food",
                                   name: "Еда",
                                   icon: "fork.knife")
    
    static let transport = CostCategory(id: "cost_transport",
                                        name: "Транспорт",
                                        icon: "car",)
    static let entertainment = CostCategory(id: "cost_entertainment",
                                            name: "Развлечения",
                                            icon: "film")
    
    static let bills = CostCategory(id: "cost_bills",
                                    name: "Счета",
                                    icon: "doc.text")
    
    static let shopping = CostCategory(id: "cost_shopping",
                                       name: "Шопинг",
                                       icon: "bag")
    
    static let healthcare = CostCategory(id: "cost_healthcare",
                                         name: "Медицина",
                                         icon: "heart")
    
    // Полный список всех предустановленных категорий трат
    static let all: [CostCategory] = [.food, .transport, .entertainment, .bills, .shopping, .healthcare]
}


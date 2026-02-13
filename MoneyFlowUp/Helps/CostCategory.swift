
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
    
    let color: Color
    
    // Группа транзакций: фиксировано .cost (траты)
    var group: TransactionGroup { .cost }
    
    // Предустановленные категории трат (для быстрого выбора пользователем)
    static let food = CostCategory(id: "cost_food",
                                   name: "Еда",
                                   icon: "fork.knife", color: .green)
    
    static let transport = CostCategory(id: "cost_transport",
                                        name: "Транспорт",
                                        icon: "car", color: .blue)
    static let entertainment = CostCategory(id: "cost_entertainment",
                                            name: "Развлечения",
                                            icon: "film", color: .orange)
    
    static let bills = CostCategory(id: "cost_bills",
                                    name: "Счета",
                                    icon: "doc.text", color: .purple)
    
    static let shopping = CostCategory(id: "cost_shopping",
                                       name: "Шопинг",
                                       icon: "bag", color: .pink)
    
    static let healthcare = CostCategory(id: "cost_healthcare",
                                         name: "Медицина",
                                         icon: "heart", color: .mint)
    
    // Полный список всех предустановленных категорий трат
    static let all: [CostCategory] = [.food, .transport, .entertainment, .bills, .shopping, .healthcare]
}


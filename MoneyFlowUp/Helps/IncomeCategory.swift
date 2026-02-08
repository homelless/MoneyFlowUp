import SwiftUI
import Foundation

// Категории для транзакций типа "Заработок".
// Соответствуют TransactionTypeProtocol и содержат цвет для UI.
struct IncomeCategory: TransactionTypeProtocol {
    var id: String          // Уникальный идентификатор категории
    let name: String        // Название категории
    let icon: String        // SF Symbol иконка
    let color: Color        // Цвет для визуального выделения
    
    // Группа транзакций — всегда доход
    var group: TransactionGroup { .income }
    
    // Предустановленные категории доходов
    static let salary = IncomeCategory(id: "income_salary",
                                       name: "Зарплата",
                                       icon: "dollarsign.circle",
                                       color: .blue)
    
    static let freelance = IncomeCategory(id: "income_freelance",
                                          name: "Фриланс",
                                          icon: "laptopcomputer",
                                          color: .blue)
    
    static let bonus = IncomeCategory(id: "income_bonus",
                                      name: "Премии",
                                      icon: "gift",
                                      color: .orange)
       
    static let investment = IncomeCategory(id: "income_investment",
                                           name: "Инвестиции",
                                           icon: "chart.line.uptrend.xyaxis",
                                           color: .green)
    
    // Полный список предустановленных категорий
    static let all: [IncomeCategory] = [.salary, .freelance, .bonus, .investment]
}


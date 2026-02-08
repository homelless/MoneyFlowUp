import Foundation
import SwiftUI

// Обертка над конкретными категориями, объединяющая их в единый тип для UI/логики.
// Позволяет работать с тратами, доходами и переводами через единый интерфейс.
enum TransactionCategory: Identifiable, Hashable {
    case cost(CostCategory)
    case income(IncomeCategory)
    case transfer(TransferType)
    
    // Единый идентификатор категории
    var id: String {
        switch self {
        case .cost(let category): return category.id
        case .income(let category): return category.id
        case .transfer(let type):  return type.id
        }
    }
    
    // Единое имя категории
    var name: String {
        switch self {
        case .cost(let category): return category.name
        case .income(let category): return category.name
        case .transfer(let type): return type.name
        }
    }
    
    // Единая иконка категории
    var icon: String {
        switch self {
        case .cost(let category): return category.icon
        case .income(let category): return category.icon
        case .transfer(let type): return type.icon
        }
    }
    
    // Группа категории (трата/доход/перевод)
    var group: TransactionGroup {
        switch self {
        case .cost: return .cost
        case .income: return .income
        case .transfer: return .transfer
        }
    }
    
    // Все категории всех групп
    static var all: [TransactionCategory] {
        CostCategory.all.map { .cost($0) } +
        IncomeCategory.all.map { .income($0) } +
        TransferType.all.map { .transfer($0) }
    }
    
    // Категории, сгруппированные по TransactionGroup
    static var byGroup: [TransactionGroup: [TransactionCategory]] {
        Dictionary(grouping: all, by: { $0.group })
    }
}


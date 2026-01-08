//
//  TransactionCategory.swift
//  MoneyFlowUp
//
//  Created by MacBookAir on 8.01.26.
//

import Foundation
import SwiftUI

enum TransactionCategory: Identifiable, Hashable {
    case cost(CostCategory)
    case income(IncomeCategory)
    case transfer(TransferType)
    
    var id: String {
        switch self {
        case .cost(let category): return category.id
        case .income(let category): return category.id
        case .transfer(let type):  return type.id
        }
    }
    
    var name: String {
            switch self {
            case .cost(let category): return category.name
            case .income(let category): return category.name
            case .transfer(let type): return type.name
            }
        }
        
    var icon: String {
            switch self {
            case .cost(let category): return category.icon
            case .income(let category): return category.icon
            case .transfer(let type): return type.icon
            }
        }
        
        var color: Color {
            switch self {
            case .cost(let category): return category.color
            case .income(let category): return category.color
            case .transfer(let type): return type.color
            }
        }
        
    var group: TransactionGroup {
            switch self {
            case .cost: return .cost
            case .income: return .income
            case .transfer: return .transfer
            }
        }
    
    static var all: [TransactionCategory] {
            CostCategory.all.map { .cost($0) } +
            IncomeCategory.all.map { .income($0) } +
            TransferType.all.map { .transfer($0) }
        }
        
    static var byGroup: [TransactionGroup: [TransactionCategory]] {
            Dictionary(grouping: all, by: { $0.group })
        }
}

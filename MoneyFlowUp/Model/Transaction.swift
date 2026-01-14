//
//  Transaction.swift
//  MoneyFlow
//
//  Created by MacBookAir on 14.12.25.
//

import Foundation
import SwiftData


struct Transaction: Identifiable {
    let id: UUID
    let amount: Double
    let category: TransactionCategory
    let date: Date
    let note: String?
    let accountId: UUID
    
    // Вычисляемые свойства
    var isExpense: Bool {
        if case .cost = category { return true }
        return false
    }
    
    var isIncome: Bool {
        if case .income = category { return true }
        return false
    }
    
    var isTransfer: Bool {
         if case .transfer = category { return true }
         return false
     }
 }

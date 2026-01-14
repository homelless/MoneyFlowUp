//
//  CostCategory.swift
//  MoneyFlowUp
//
//  Created by MacBookAir on 8.01.26.
//
import SwiftUI
import Foundation

struct CostCategory: TransactionTypeProtocol {
    var id: String
    let name: String
    let icon: String
    let color: Color
    
    var group: TransactionGroup { .cost }
    
    static let food = CostCategory(id: "cost_food",
                                   name: "Food",
                                   icon: "fork.knife",
                                   color: .orange)
    
    static let transport = CostCategory(id: "cost_transport",
                                        name: "Transport",
                                        icon: "car",
                                        color: .blue)
    
    static let all: [CostCategory] = [.food, .transport]
    
}

//
//  IncomeCategory.swift
//  MoneyFlowUp
//
//  Created by MacBookAir on 8.01.26.
//

import SwiftUI
import Foundation

struct IncomeCategory: TransactionTypeProtocol {
    var id: String
    let name: String
    let icon: String
    let color: Color
    
    var group: TransactionGroup { .income }
    
    static let salary = IncomeCategory(id: "income_salary",
                                       name: "Salary",
                                       icon: "dollarsign.circle",
                                       color: .blue,
       )
    
    static let freelance = IncomeCategory(id: "income_freelance",
                                           name: "Freelance",
                                           icon: "laptopcomputer",
                                           color: .blue)
    
    static let all: [IncomeCategory] = [.salary, .freelance]
    
}

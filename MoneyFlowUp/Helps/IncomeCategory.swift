

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
    
    static let bonus = IncomeCategory(id: "income_bonus",
                                         name: "Bonus",
                                         icon: "gift",
                                         color: .orange)
       
       static let investment = IncomeCategory(id: "income_investment",
                                              name: "Investment",
                                              icon: "chart.line.uptrend.xyaxis",
                                              color: .green)
       
    
    static let all: [IncomeCategory] = [.salary, .freelance, .bonus, .investment]
}

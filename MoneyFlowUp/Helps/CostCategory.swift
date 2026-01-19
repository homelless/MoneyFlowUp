
import SwiftUI
import Foundation

struct CostCategory: TransactionTypeProtocol {
    
    var id: String
    let name: String
    let icon: String
    
    var group: TransactionGroup { .cost }
    
    static let food = CostCategory(id: "cost_food",
                                   name: "Food",
                                   icon: "fork.knife")
    
    static let transport = CostCategory(id: "cost_transport",
                                        name: "Transport",
                                        icon: "car",)
    static let entertainment = CostCategory(id: "cost_entertainment",
                                            name: "Entertainment",
                                            icon: "film")
    
    static let bills = CostCategory(id: "cost_bills",
                                    name: "Bills",
                                    icon: "doc.text")
    
    static let shopping = CostCategory(id: "cost_shopping",
                                       name: "Shopping",
                                       icon: "bag")
    
    static let healthcare = CostCategory(id: "cost_healthcare",
                                         name: "Healthcare",
                                         icon: "heart")
    
    static let all: [CostCategory] = [.food, .transport, .entertainment, .bills, .shopping, .healthcare]
}

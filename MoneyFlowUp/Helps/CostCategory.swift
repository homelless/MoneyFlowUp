
import SwiftUI
import Foundation

struct CostCategory: TransactionTypeProtocol {
    
    var id: String
    let name: String
    let icon: String
    
    var group: TransactionGroup { .cost }
    
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
                                         name: "Медецина",
                                         icon: "heart")
    
    static let all: [CostCategory] = [.food, .transport, .entertainment, .bills, .shopping, .healthcare]
}

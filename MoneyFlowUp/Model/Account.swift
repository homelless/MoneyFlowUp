
import Foundation
import SwiftData
import SwiftUI

@Model
class Account: Identifiable, Hashable {
    var id: UUID
    var name: String
    var balance: String
 //   var transactions: [Transaction]?
    var currencyRaw: String
    var currency: Currency {
        get { Currency(rawValue: currencyRaw) ?? .usd }
        set { currencyRaw = newValue.rawValue } }
    var descriptionAccount: String
    var sortOrder: Int
    
    init(id: UUID, name: String, balance: String, currencyRaw: String, descriptionAccount: String, sortOrder: Int = 0) {
        self.id = id
        self.name = name
        self.balance = balance
        self.currencyRaw = currencyRaw
        self.descriptionAccount = descriptionAccount
        self.sortOrder = sortOrder  
    }
    
    // Для Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Account, rhs: Account) -> Bool {
        lhs.id == rhs.id
    }
}

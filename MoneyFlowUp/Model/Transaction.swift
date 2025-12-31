//
//  Transaction.swift
//  MoneyFlow
//
//  Created by MacBookAir on 14.12.25.
//

import Foundation
import SwiftData

@Model
class Transaction: Identifiable, Hashable {
    
    var id: UUID
    var amount: Double
    var category: CategoryTransaction?
    var date: Date
    var account: Account?
    
    init(id: UUID, amount: Double, category: CategoryTransaction, date: Date, account: Account? = nil) {
        self.id = id
        self.amount = amount
        self.category = category
        self.date = date
        self.account = account
    }
}

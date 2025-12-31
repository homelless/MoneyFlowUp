//
//  TransactionType.swift
//  MoneyFlow
//
//  Created by MacBookAir on 15.12.25.
//

import Foundation
import SwiftData

@Model
class CategoryTransaction: Identifiable {
    var id: UUID
    var name: String
    
    init(id: UUID, name: String) {
        self.id = id
        self.name = name
    }
}

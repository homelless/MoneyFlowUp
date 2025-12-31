//
//  Item.swift
//  MoneyFlowUp
//
//  Created by MacBookAir on 31.12.25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}

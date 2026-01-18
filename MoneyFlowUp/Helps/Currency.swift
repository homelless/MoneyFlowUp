//
//  Currency.swift
//  MoneyFlow
//
//  Created by MacBookAir on 22.12.25.
//

import Foundation
import SwiftUI


 enum Currency: String, CaseIterable, Identifiable, Codable {
    
        case usd = "$"
        case rub = "₽"
        case eur = "€"
    
    public var id: String { rawValue }
}

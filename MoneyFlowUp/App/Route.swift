//
//  Route.swift
//  MoneyFlow
//
//  Created by MacBookAir on 27.12.25.
//

import Foundation

enum Route: Hashable {
    
    case add
    case detail(Account)
    case addTransaction
}

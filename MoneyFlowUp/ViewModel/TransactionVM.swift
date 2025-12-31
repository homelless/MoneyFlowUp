//
//  TransactionVM.swift
//  MoneyFlowUp
//
//  Created by MacBookAir on 31.12.25.
//

import Foundation
import SwiftData
import Observation
import SwiftUI
import Combine




@Observable
@MainActor
final  class TransactionVM: Identifiable {
    
    
    var transactions: [Transaction] = []
    
    func addTransaction(_ transaction: Transaction) {
        transactions.append(transaction)
    }
    
    func removeTransaction(at offsets: IndexSet) {
        transactions.remove(atOffsets: offsets)
    }
}

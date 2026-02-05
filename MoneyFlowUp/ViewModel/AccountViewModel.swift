//
//  AccountViewModel.swift
//  MoneyFlow
//
//  Created by MacBookAir on 16.12.25.
//

import Foundation
import SwiftData
import SwiftUI
import Combine
import Observation


@Observable
@MainActor
final class AccountViewModel: Identifiable {
    
   var accounts: [Account] = [
        Account(id:.init(), name: "кошелек", balance: "1000", currencyRaw: "USD", descriptionAccount: ""),
            Account(id: .init(), name: "карта", balance: "5000",currencyRaw: "USD", descriptionAccount: ""),
            Account(id: .init(),name: "сбережения", balance: "32000",currencyRaw: "USD", descriptionAccount: "")
        ]
    
    func addAccount(_ account: Account) {
        accounts.append(account)
    }
    
    func removeAccount(at offsets: IndexSet) {
        accounts.remove(atOffsets: offsets)
    }
    
    func moveAccount(from source: IndexSet, to destination: Int) {
        accounts.move(fromOffsets: source, toOffset: destination)
        
        // Обновляем sortOrder для всех элементов
        for (index, account) in accounts.enumerated() {
            account.sortOrder = index
        }
    }
    
    func updateAccount(id: UUID, name: String, balance: String, currencyRaw: String, descriptionAccount: String) {
        guard let index = accounts.firstIndex(where: { $0.id == id }) else { return }
        accounts[index].name = name
        accounts[index].balance = balance
        accounts[index].currencyRaw = currencyRaw
        accounts[index].descriptionAccount = descriptionAccount
       
    }
}

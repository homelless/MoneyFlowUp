//
//  CatogotyRow.swift
//  MoneyFlow
//
//  Created by MacBookAir on 15.12.25.
//

import SwiftUI
import SwiftData

struct AccountRow: View {
    let account: Account
   
    
    var body: some View {
        HStack {
            Image(systemName: "wallet.bifold")
                .resizable()
                .frame(width: 30, height: 30)
                .foregroundStyle(Color.init("ColorMoney"))
                
            VStack(alignment: .leading) {
                Text(account.name)
                    .font(.headline)
                    .foregroundStyle(Color.init("ColorMoney"))
                    .lineLimit(1)
                HStack{
                    Text("\(account.balance.description)\(account.currency.rawValue)")
                        .font(.subheadline)
                        .foregroundStyle(Color.init("ColorMoney"))
                        .lineLimit(1)
                }
            }
        }
    }
}

#Preview {
    AccountRow(account: Account(id: .init(), name: "test", balance: "1000", currencyRaw: "$", descriptionAccount: ""))
}

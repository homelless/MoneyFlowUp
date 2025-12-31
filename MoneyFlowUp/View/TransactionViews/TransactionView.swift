//
//  TransactionView.swift
//  MoneyFlow
//
//  Created by MacBookAir on 30.12.25.
//

import SwiftUI

struct TransactionView: View {
    @State var selectionPicker = 0
    let selectionItems : [String] = [
        "income",
        "cost",
        "transfer"
    ]
    
    
    
    var body: some View {
        
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
            
            TabView {
                Tab("cost", systemImage: "cart.badge.plus") { }
                Tab("income", systemImage: "dollarsign.ring.dashed") { }
                Tab("transfer", systemImage: "arrow.triangle.2.circlepath") { }
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 100)
                
                
                
                VStack(alignment: .center) {
                    Text("Transaction")
                        .font(.title)
                    
                    
                    Spacer()
                }
            }
        }
    }
}

#Preview {
    TransactionView()
}

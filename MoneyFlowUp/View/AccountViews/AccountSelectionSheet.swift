

import SwiftUI

 struct AccountSelectionSheet: View {
    let title: String
    let accounts: [Account]
    let selected: Account?
    let onSelect: (Account) -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color("фон").ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color("текст"))
                    Spacer()
                }
                .padding()
                
                List {
                    ForEach(accounts) { account in
                        Button {
                            onSelect(account)
                            dismiss()
                        } label: {
                            HStack {
                                HStack {
                                    Text(account.name)
                                        .foregroundStyle(Color("текст"))
                                    Spacer()
                                    Text("\(account.balance) \(account.currencyRaw)")
                                        .foregroundStyle(Color("текст"))
                                }
                                Spacer()
                                if selected?.id == account.id {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(Color("текст"))
                                }
                            }
                            .contentShape(Rectangle())
                        }
                        .listRowBackground(Color("ячейка"))
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .presentationDetents([.medium, .large])
    }
}

import SwiftUI

struct AccountListView: View {
    
    @Bindable var accountVM: AccountViewModel
    @Bindable var transactionVM: TransactionVM
    @Binding var path: [Route]

    var body: some View {
        ZStack {
            Color("ColorSet")
                .ignoresSafeArea()
            
            VStack {
                HStack(alignment: .top) {
                    Button {
                        path.append(.calendar(Date()))
                    } label: {
                        Text(.now, format: .dateTime.day().month(.wide))
                            .font(.title)
                            .italic()
                            .frame(maxWidth: 260, alignment: .center)
                            .environment(\.locale, Locale(identifier: "ru_RU"))

                    }
                    .buttonStyle(.plain)
                    .padding(.leading, 40)
                    
                    Button {
                        path.append(.addAccount)
                    } label: {
                        Image(systemName: "plus")
                    }
                    .font(.largeTitle)
                    .tint(.black)
                    .padding(.leading, 10)
                }
                
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 0.5)
                
                List {
                    ForEach(accountVM.accounts, id:\.id) { account in
                        Button {
                            path.append(.detail(account.id))
                        } label: {
                            AccountRow(account: account)
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color("ColorSet").opacity(0.9))
                                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.black, lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                        .tint(.clear)
                        .frame(height: 65)
                        .contentShape(Rectangle())
                        .listRowBackground(Color.clear)
                        .listRowInsets(.none)
                        .listRowSeparator(.hidden)
                    }
                    .onDelete { indexSet in
                        accountVM.removeAccount(at: indexSet)
                    }
                    .onMove { indices, newOffset in
                        accountVM.moveAccount(from: indices, to: newOffset)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(.plain)
            }
        }
        
        .safeAreaInset(edge: .bottom) {
            GeometryReader { proxy in
                HStack {
                    Spacer()
                    Button(action: {
                        path.append(.addTransaction)
                    }) {
                        Text("добавить транзакцию")
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .frame(width: proxy.size.width * 0.85, height: 50) // 90% ширины, фиксированная высота
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color("addColor")).opacity(0.9)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.black, lineWidth: 1)
                            )
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 20))
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 8)
                .padding(.bottom, 16)
            }
            .frame(height: 50 + 8 + 16) // высота inset под кнопку и отступы
        }
        .navigationDestination(for: Route.self) { route in
            switch route {
            case .addTransaction:
                TransactionView(transactionVM: transactionVM, accountVM: accountVM, path: $path)
    
            case .detail(let accountID):
                if let account = accountVM.accounts.first(where: { $0.id == accountID }) {
                    AccountDetailView(account: account, accountVM: accountVM)
                } else {
                    Text("Кошелек не найден")
                }
            case .addAccount:
                AccountAddView(viewModel: accountVM)
            case .calendar(let date):
                TransactionsCalendarView(selectedDate: date, transactionVM: transactionVM, accountVM: accountVM)
            }
        }
    }
}

#Preview {
    AccountListView(accountVM: AccountViewModel(), transactionVM: TransactionVM(), path: .constant([]))
}


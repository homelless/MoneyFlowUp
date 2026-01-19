



import SwiftUI


struct AccountListView: View {
    
    @Bindable var viewModel: AccountViewModel
    @Binding var path: [Route]
    
    
    var body: some View {
        ZStack {
            // общий фон для всего экрана
            Color("ColorSet")
                .ignoresSafeArea()
            
            VStack {
                HStack(alignment: .top) {
                    Text(.now, format: .dateTime.day().month(.wide))
                        .font(.title)
                        .italic()
                        .frame(maxWidth: 260, alignment: .center)
                        .padding(.leading, 40)
                    
                    Button {
                        path.append(.add)
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
                    ForEach(viewModel.accounts, id:\.id) { account in
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
                        .listRowBackground(Color.clear)    // ← ПРАВИЛЬНО: применяется к строке списка
                        .listRowInsets(.none)             // ← ПРАВИЛЬНО: применяется к строке списка
                        .listRowSeparator(.hidden)        // ← ПРАВИЛЬНО: применяется к строке списка
                    }
                    .onDelete { indexSet in
                        viewModel.removeAccount(at: indexSet)
                    }
                    .onMove { indices, newOffset in
                        viewModel.moveAccount(from: indices, to: newOffset)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .listStyle(.plain)
                .toolbar {
                    EditButton()
                }
                }
            }
        }
    }




#Preview {
    AccountListView(viewModel: AccountViewModel(), path: .constant([]))
}

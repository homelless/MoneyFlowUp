import SwiftUI

struct CompactDatePicker: View {
    let title: String?
    @Binding var selection: Date
    @State private var showPicker = false
    
    // Форматтер для "дд.мм.гг"
    static let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "dd.MM.yy"
        return f
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let title, !title.isEmpty {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Color(.текст))
            }
            Button {
                showPicker = true
            } label: {
                HStack {
                    Text(Self.formatter.string(from: selection))
                        .font(.headline)
                        .foregroundStyle(Color(.текст))
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                }
                .padding(8)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.ячейка))
                .cornerRadius(8)
            }
            .sheet(isPresented: $showPicker) {
                DatePicker("", selection: $selection, displayedComponents: .date)
                    .datePickerStyle(.graphical)
                    .labelsHidden()
                    .presentationDetents([.medium])
                    .environment(\.locale, Locale(identifier: "ru_RU"))
                    .padding()
                    .onChange(of: selection) { _ in
                        showPicker = false
                    }
            }
        }
    }
}

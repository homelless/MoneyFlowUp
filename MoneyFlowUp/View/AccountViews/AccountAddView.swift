import SwiftUI

// Экран добавления нового кошелька.
// Позволяет ввести имя, баланс, валюту и описание, затем сохраняет через AccountViewModel.
struct AccountAddView: View {
    
    // ViewModel для работы с кошельками
    @Bindable var viewModel: AccountViewModel
    // Локальное состояние создаваемого аккаунта
    @State var account = Account(id: .init(), name: "", balance: "", currencyRaw: "", descriptionAccount: "")
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    // Локальный десятичный разделитель (из текущей локали)
    private var localDecimalSeparator: String {
        Locale.current.decimalSeparator ?? ","
    }
    // Альтернативный разделитель (если локальный ",", то альтернативный ".")
    private var alternateDecimalSeparator: String {
        localDecimalSeparator == "," ? "." : ","
    }
    
    var body: some View {
        
        ZStack {
            // Фоновый цвет
            Color("фон").ignoresSafeArea()
            VStack {
                Form {
                    // Имя кошелька
                    Section("Название") {
                        TextField("", text: $account.name)
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Начальный баланс
                    Section("Баланс") {
                        TextField("0", text: $account.balance)
                            .keyboardType(.decimalPad)
                            .onChange(of: account.balance) { _, newValue in
                                account.balance = normalizeDecimalInput(newValue)
                            }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Выбор валюты
                    Section("Валюта") {
                        Picker("", selection: $account.currencyRaw) {
                            ForEach(Currency.allCases) { currency in
                                Text(currency.rawValue)
                                    .tag(currency.rawValue) // selection is String, tag must be String
                                    .foregroundColor(.текст)
                            }
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    .foregroundColor(.текст)
                    .tint(.текст)
                    // Описание
                    Section("Описание") {
                        ZStack(alignment: .topLeading) {
                            // Placeholder
                            if account.descriptionAccount.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                Text("Описание(необязательно)")
                                    .foregroundColor(.secondary)
                                    .padding(.top, 8)
                                    .padding(.leading, 5)
                            }
                            TextEditor(text: $account.descriptionAccount)
                                .frame(height: 200)
                                .scrollContentBackground(.hidden)
                                .background(Color.clear)
                        }
                    }
                    .listRowBackground(Color("ячейка"))
                    .foregroundStyle(Color("текст"))
                    // Кнопка сохранения
                    Section() {
                        Button("Добавить кошелек") {
                            viewModel.addAccount(account)
                            dismiss()
                        }
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color("ячейка"))
                        .foregroundStyle(Color("текст"))
                        // Блокируем кнопку, если имя/баланс пустые/из пробелов
                        .disabled(account.name.trimmingCharacters(in: .whitespaces).isEmpty || account.balance.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
                .scrollContentBackground(.hidden)
                .navigationTitle(Text("Создание кошелька"))
            }
        }
    }
    
    // Фильтрация и нормализация десятичного ввода:
    private func normalizeDecimalInput(_ input: String) -> String {
        // Заменим все альтернативные разделители на локальный для унификации
        var value = input.replacingOccurrences(of: alternateDecimalSeparator, with: localDecimalSeparator)
        
        // Разрешенные символы: цифры и локальный разделитель
        let allowed = Set("0123456789" + localDecimalSeparator)
        value = value.filter { allowed.contains($0) }
        
        // Разрешаем только один разделитель
        if let firstSepRange = value.range(of: localDecimalSeparator) {
            let afterFirst = value[firstSepRange.upperBound...]
            let cleanedAfter = afterFirst.replacingOccurrences(of: localDecimalSeparator, with: "")
            value = value[..<firstSepRange.upperBound] + cleanedAfter
        }
        
        // Если начинается с разделителя — добавим ведущий 0
        if value.hasPrefix(localDecimalSeparator) {
            value = "0" + value
        }
        
        // Удалим ведущие нули перед целой частью, но оставим один ноль, если строка пустеет
        // Пример: "00012,3" -> "12,3"; "000" -> "0"; "000,5" -> "0,5"
        value = trimLeadingZerosPreservingDecimal(value, separator: localDecimalSeparator)
        
        return value
    }
    
    private func trimLeadingZerosPreservingDecimal(_ s: String, separator: String) -> String {
        var str = s
        // Если есть разделитель, работаем с целой частью отдельно
        if let sepRange = str.range(of: separator) {
            var intPart = String(str[..<sepRange.lowerBound])
            let fracPart = String(str[sepRange.lowerBound...]) // включая разделитель
            // Удаляем лидирующие нули в целой части
            intPart = String(intPart.drop(while: { $0 == "0" }))
            if intPart.isEmpty { intPart = "0" }
            return intPart + fracPart
        } else {
            // Без дробной части — оставляем один ноль, если все нули
            let trimmed = String(str.drop(while: { $0 == "0" }))
            return trimmed.isEmpty ? "0" : trimmed
        }
    }
}


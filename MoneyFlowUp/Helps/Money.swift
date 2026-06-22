import Foundation

// Денежные утилиты: единое место для парсинга ввода, точной конвертации и форматирования сумм.
// Деньги храним и считаем в Decimal, чтобы не накапливать погрешность двоичного Double.

extension Decimal {
    // Точное преобразование суммы из Double в Decimal через строку.
    // Decimal(Double) тянет двоичные артефакты (0.1 -> 0.1000000000000000055),
    // а Decimal(string: String(value)) даёт чистое десятичное значение для обычных денежных сумм.
    init(money value: Double) {
        self = Decimal(string: String(value)) ?? Decimal(value)
    }

    // Представление для UI: до 2 знаков после запятой, без научной нотации.
    var moneyString: String {
        Self.displayFormatter.string(from: self as NSDecimalNumber) ?? "0"
    }

    private static let displayFormatter: NumberFormatter = {
        let f = NumberFormatter()
        f.numberStyle = .decimal
        f.minimumFractionDigits = 0
        f.maximumFractionDigits = 2
        f.usesGroupingSeparator = false
        return f
    }()
}

extension String {
    // Парсинг пользовательского ввода баланса в Decimal: принимает запятую/точку и пробелы-разделители.
    var moneyDecimal: Decimal? {
        let normalized = self
            .replacingOccurrences(of: "\u{00A0}", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: ",", with: ".")
        guard !normalized.isEmpty else { return nil }
        return Decimal(string: normalized)
    }
}

import Foundation
import SwiftUI

// Общий протокол для типов категорий транзакций.
// Гарантирует наличие id, name, icon и принадлежности к группе.
protocol TransactionTypeProtocol: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var group: TransactionGroup { get }
}


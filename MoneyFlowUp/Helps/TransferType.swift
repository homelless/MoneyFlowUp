import SwiftUI
import Foundation

// Тип перевода (категория для TransactionGroup.transfer).
// Соответствует TransactionTypeProtocol, содержит флаг необходимости целевого аккаунта.
struct TransferType: TransactionTypeProtocol {
    let id: String                 // Уникальный идентификатор
    let name: String               // Название типа перевода
    let icon: String               // SF Symbol иконка
    let color: Color               // Цвет для UI
    let requiresTargetAccount: Bool // Требуется ли указание целевого аккаунта
    
    // Группа транзакций — всегда перевод
    var group: TransactionGroup { .transfer }
    
    // Предустановленный тип перевода между кошельками
    static let accountTransfer = TransferType(
        id: "transfer_account",
        name: "Кошелек",
        icon: "arrow.left.arrow.right",
        color: .blue,
        requiresTargetAccount: true
    )
    
    // Полный список доступных типов перевода
    static let all: [TransferType] = [.accountTransfer]
}


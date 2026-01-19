
import SwiftUI
import Foundation

struct TransferType: TransactionTypeProtocol {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let requiresTargetAccount: Bool
    
    var group: TransactionGroup { .transfer }
    
    static let accountTransfer = TransferType(
        id: "transfer_account",
        name: "Account Transfer",
        icon: "arrow.left.arrow.right",
        color: .blue,
        requiresTargetAccount: true
    )
    
    static let all: [TransferType] = [.accountTransfer]
}

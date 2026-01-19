
import Foundation
import SwiftUI

protocol TransactionTypeProtocol: Identifiable, Hashable {
    var id: String { get }
    var name: String { get }
    var icon: String { get }
    var group: TransactionGroup { get }
}

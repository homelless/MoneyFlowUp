
import Foundation

enum Route: Hashable {
    
    case addAccount
    case detail(Account.ID)
    case addTransaction
}

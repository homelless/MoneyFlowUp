
import Foundation

enum Route: Hashable {
    
    case add
    case detail(Account.ID)
    case addTransaction
}

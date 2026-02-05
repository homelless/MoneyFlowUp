import Foundation

enum Route: Hashable {
    
    case addAccount
    case detail(Account.ID)
    case addTransaction
    case calendar(Date)
}


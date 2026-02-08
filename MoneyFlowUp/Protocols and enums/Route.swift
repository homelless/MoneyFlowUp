import Foundation

// Маршруты навигации внутри приложения.
// Используется вместе с NavigationStack/Path.
enum Route: Hashable {
    
    case addAccount           // Экран добавления аккаунта
    case detail(Account.ID)   // Детали аккаунта по его ID
    case addTransaction       // Экран добавления транзакции
    case calendar(Date)       // Экран календаря для конкретной даты
}


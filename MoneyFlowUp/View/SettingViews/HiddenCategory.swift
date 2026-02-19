import Foundation
import SwiftData


//модель SwiftData, которая хранит id предустановленных категорий, которые пользователь «скрыл»
@Model
final class HiddenCategory {
    @Attribute(.unique) var id: String

    init(id: String) {
        self.id = id
    }
}

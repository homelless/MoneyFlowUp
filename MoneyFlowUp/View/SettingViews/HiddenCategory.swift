import Foundation
import SwiftData

@Model
final class HiddenCategory {
    @Attribute(.unique) var id: String

    init(id: String) {
        self.id = id
    }
}

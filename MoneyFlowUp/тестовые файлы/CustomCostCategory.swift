import Foundation
import SwiftData

@Model
final class CustomCostCategory {
    var id: String
    var name: String
    var icon: String

    init(id: String, name: String, icon: String) {
        self.id = id
        self.name = name
        self.icon = icon
    }
}

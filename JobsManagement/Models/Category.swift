import Foundation
import SwiftData

@Model
final class Category {
    var id: UUID = UUID()
    var name: String = ""
    var iconName: String = ""
    var colorHex: String = ""
    var categoryType: TaskCategoryType = TaskCategoryType.custom
    var isCustom: Bool = false

    @Relationship(deleteRule: .nullify, inverse: \JobTask.category)
    var tasks: [JobTask]?

    init(
        id: UUID = UUID(),
        name: String,
        iconName: String,
        colorHex: String,
        categoryType: TaskCategoryType,
        isCustom: Bool = false
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.categoryType = categoryType
        self.isCustom = isCustom
    }
}

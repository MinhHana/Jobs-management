import Foundation
import SwiftData

struct CategorySeeder {
    private struct DefaultCategory {
        let name: String
        let iconName: String
        let colorHex: String
        let categoryType: TaskCategoryType
    }

    private static let defaults: [DefaultCategory] = [
        DefaultCategory(name: "Cá nhân", iconName: "person.fill", colorHex: "#5AC8FA", categoryType: .personal),
        DefaultCategory(name: "Công việc", iconName: "briefcase.fill", colorHex: "#FF9500", categoryType: .work),
        DefaultCategory(name: "Dự định", iconName: "map.fill", colorHex: "#AF52DE", categoryType: .plans),
        DefaultCategory(name: "Học tập", iconName: "book.fill", colorHex: "#34C759", categoryType: .study),
        DefaultCategory(name: "Sức khỏe", iconName: "heart.fill", colorHex: "#FF2D55", categoryType: .health),
        DefaultCategory(name: "Tài chính", iconName: "dollarsign.circle.fill", colorHex: "#FFD60A", categoryType: .finance),
        DefaultCategory(name: "Nhà cửa", iconName: "house.fill", colorHex: "#007AFF", categoryType: .home),
    ]

    /// UUID cố định theo loại — tránh trùng danh mục khi sync iCloud giữa nhiều thiết bị.
    private static func stableID(for type: TaskCategoryType) -> UUID {
        switch type {
        case .personal: UUID(uuidString: "A1000001-0000-4000-8000-000000000001")!
        case .work: UUID(uuidString: "A1000002-0000-4000-8000-000000000002")!
        case .plans: UUID(uuidString: "A1000003-0000-4000-8000-000000000003")!
        case .study: UUID(uuidString: "A1000004-0000-4000-8000-000000000004")!
        case .health: UUID(uuidString: "A1000005-0000-4000-8000-000000000005")!
        case .finance: UUID(uuidString: "A1000006-0000-4000-8000-000000000006")!
        case .home: UUID(uuidString: "A1000007-0000-4000-8000-000000000007")!
        case .custom: UUID()
        }
    }

    /// Chèn danh mục mặc định còn thiếu (theo categoryType, an toàn với iCloud sync).
    @discardableResult
    static func seedDefaults(in context: ModelContext) throws -> [Category] {
        let existing = try context.fetch(FetchDescriptor<Category>())
        let existingDefaultTypes = Set(
            existing.filter { !$0.isCustom }.map(\.categoryType)
        )

        var seeded: [Category] = []

        for item in defaults where !existingDefaultTypes.contains(item.categoryType) {
            let category = Category(
                id: stableID(for: item.categoryType),
                name: item.name,
                iconName: item.iconName,
                colorHex: item.colorHex,
                categoryType: item.categoryType,
                isCustom: false
            )
            context.insert(category)
            seeded.append(category)
        }

        if !seeded.isEmpty {
            try context.save()
        }

        return existing + seeded
    }
}

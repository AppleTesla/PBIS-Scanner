// MARK: Imports

import Foundation

// MARK: Extensions

extension Behavior: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Behavior.keys)

        // TODO: A better way to generalize this? ++ Duplicated
        do {
            let id_integer = try values.decode(Int.self, forKey: .id)
            id = String(id_integer)
        } catch {
            id = try values.decode(String.self, forKey: .id)
        }

        title = try values.decode(String.self, forKey: .title)

        let location_string = try values.decode(String.self, forKey: .location)
        location = Location(name: location_string)

        // TODO: Find alternative to default value for mismatched category
        let category_string = try values.decode(String.self, forKey: .category)
        category = Category(rawValue: category_string) ?? .safe
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Behavior.keys)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(location, forKey: .location)
        try container.encode(category, forKey: .category)
    }
}

extension Behavior: Equatable {
    public static func ==(lhs: Behavior, rhs: Behavior) -> Bool {
        return lhs.id == rhs.id
    }
}

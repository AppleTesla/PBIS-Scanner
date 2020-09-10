// MARK: Imports

import Foundation

// MARK: Extensions

extension Location: Identifiable { }

extension Location: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = Location(name: value)
    }
}

extension Location: Codable {
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Location.keys)

        name = try values.decode(String.self, forKey: .name)
        id = name
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Location.keys)

        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
    }
}

extension Location: Equatable {
    public static func ==(lhs: Location, rhs: Location) -> Bool {
        return lhs.name.uppercased() == rhs.name.uppercased()
    }
}

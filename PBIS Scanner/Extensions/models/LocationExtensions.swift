// MARK: Imports

import Foundation

// MARK: Extensions

extension Location: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = Location(name: value)
    }

//    public init(from decoder: Decoder) throws {
//        let values = try decoder.container(keyedBy: Location.keys)
//
//        id = try values.decode(String.self, forKey: .id)
//        name =
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: Location.keys)
//
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//    }
}

// MARK: Imports

import Foundation

// MARK: Extensions

extension Juvenile: Codable {

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: Juvenile.keys)

        // TODO: A better way to generalize this? ++ Duplicated
        do {
            let id_integer = try values.decode(Int.self, forKey: .id)
            id = String(id_integer)
        } catch {
            id = try values.decode(String.self, forKey: .id)
        }

        first_name = try values.decode(String.self, forKey: .first_name)
        last_name = try values.decode(String.self, forKey: .last_name)
        points = try values.decode(Int.self, forKey: .points)
        event_id = try values.decode(Int.self, forKey: .event_id)
        active = try values.decode(Int.self, forKey: .active)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: Juvenile.keys)

        try container.encode(id, forKey: .id)
        try container.encode(first_name, forKey: .first_name)
        try container.encode(last_name, forKey: .last_name)
        try container.encode(points, forKey: .points)
        try container.encode(event_id, forKey: .event_id)
        try container.encode(active, forKey: .active)
    }

    // TODO: Can this be used?
    private func decodeId<T>(_ id: T) -> String {
        if let id = id as? Int {
            return String(id)
        }
        return id as! String
    }
}
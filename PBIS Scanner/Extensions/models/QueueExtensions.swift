// MARK: Imports

import Foundation

// MARK: Extensions

extension Queue: Identifiable { }

extension Queue: Equatable {
    public static func ==(lhs: Queue, rhs: Queue) -> Bool {
        return lhs.id == rhs.id
    }
}

extension Queue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(juveniles?.shuffled())
//        hasher.combine(owner)
    }
}

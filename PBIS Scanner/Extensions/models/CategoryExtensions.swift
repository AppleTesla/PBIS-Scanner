// MARK: Imports

import Foundation

// MARK: Extensions

extension Category: CaseIterable {
    public static var allCases: [Category] {
        return [.safe, .responsible, .considerate]
    }
}

extension Category {
    var stringValue: String {
        switch self {
        case .safe:
            return "Safe"
        case .responsible:
            return "Responsible"
        case .considerate:
            return "Considerate"
        }
    }
}

extension Category {
    func next() -> Category {
        return Category.allCases[(Category.allCases.firstIndex(of: self)! + 1) % 3]
    }
}

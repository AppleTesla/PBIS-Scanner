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
    func next(state: Category) -> Category {
        return Category.allCases[(Category.allCases.firstIndex(of: state)! + 1) % Category.allCases.count]
    }
}

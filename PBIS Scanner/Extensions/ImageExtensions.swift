// MARK: Imports

import SwiftUI

// MARK: Extensions

extension Image {
    init(_ systemName: SystemImage) {
        self.init(systemName: systemName.rawValue)
    }
}

extension UIImage {
    convenience init?(_ systemName: SystemImage) {
        self.init(systemName: systemName.rawValue)
    }
}

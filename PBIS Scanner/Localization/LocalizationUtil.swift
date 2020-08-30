// MARK: Imports

import Foundation
import SwiftUI

// MARK: Utilities

public func localized(_ key: String, tableName: String? = nil, bundle: Bundle = Bundle.main, value: String = "", comment: String = "") -> String {
    let fallbackLanguage = "en"
    guard let fallbackBundlePath = Bundle.main.path(forResource: fallbackLanguage, ofType: "lproj") else { return key }
    guard let fallbackBundle = Bundle(path: fallbackBundlePath) else { return key }
    let fallbackString = fallbackBundle.localizedString(forKey: key, value: comment, table: nil)
    return Bundle.main.localizedString(forKey: key, value: fallbackString, table: nil)
}

extension Text {
    init(_ localizationKey: LocalizationKey) {
        self.init(localized(localizationKey.rawValue))
    }
}

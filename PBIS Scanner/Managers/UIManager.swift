// MARK: Imports

import UIKit

// MARK: Classes

final class UIManager: ObservableObject {

    /// This should be no larger than 25
    let tabIconSize: CGFloat = 23

}

// MARK: Color Provisioning

extension UIManager {
    /// Credit to Anoop from Medium at: https://medium.com/@anoopm6/swift-generate-color-hash-uicolor-from-string-names-e0aa129fec6a
    func generateColorFor(text: String) -> UIColor {
        var hash = 0
        let colorConstant = 131
        let maxSafeValue = Int.max / colorConstant
        for char in text.unicodeScalars{
            if hash > maxSafeValue {
                hash = hash / colorConstant
            }
            hash = Int(char.value) + ((hash << 5) - hash)
        }
        let finalHash = abs(hash) % (256*256*256);
        //let color = UIColor(hue:CGFloat(finalHash)/255.0 , saturation: 0.40, brightness: 0.75, alpha: 1.0)
        let color = UIColor(red: CGFloat((finalHash & 0xFF0000) >> 16) / 255.0, green: CGFloat((finalHash & 0xFF00) >> 8) / 255.0, blue: CGFloat((finalHash & 0xFF)) / 255.0, alpha: 1.0)
        return color
    }
}

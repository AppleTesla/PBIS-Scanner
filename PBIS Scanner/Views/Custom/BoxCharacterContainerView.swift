// MARK: Imports

import SwiftUI

// MARK: Views

struct BoxStringContainerView: View {
    var text: String
    var body: some View {
        ZStack(alignment: .center) {
            Circle()
                .foregroundColor(.white)
            Text(text)
                .foregroundColor(.red)
                .fontWeight(.bold)
        }
    }
}

struct BoxCounterView_Previews: PreviewProvider {
    static var previews: some View {
        BoxStringContainerView(text: "Test")
    }
}

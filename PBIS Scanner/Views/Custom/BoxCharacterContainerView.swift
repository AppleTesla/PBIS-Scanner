// MARK: Imports

import SwiftUI

// MARK: Views

struct BoxStringContainerView: View {
    var text: String
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.red)
            Text(text)
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
    }
}

struct BoxCounterView_Previews: PreviewProvider {
    static var previews: some View {
        BoxStringContainerView(text: "Test")
    }
}

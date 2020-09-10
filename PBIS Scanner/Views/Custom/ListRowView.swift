// MARK: Imports

import SwiftUI

// MARK: Views

struct ListRowView: View {
    let key: Text
    let value: Text

    var body: some View {
        HStack {
            key; Spacer(); value
        }
    }
}

struct ListRowView_Previews: PreviewProvider {
    static var previews: some View {
        ListRowView(key: Text("key"), value: Text("value"))
    }
}

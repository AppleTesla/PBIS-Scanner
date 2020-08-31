// MARK: Imports

import SwiftUI

// MARK: Views

struct QueueDrawer: View {

    // MARK: Environment Objects

    @EnvironmentObject private var qm: QueueManager

    // MARK: View Properties

    var body: some View {
        VStack {
            Spacer()

            // MINIMIZED

            VStack(spacing: 35) {
                HStack(spacing: 15) {
                    Image(.viewfinder)
                    .resizable()
                    .frame(width: 50, height: 50)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(.sessionAlertTitle)
                        Text(.sessionAlertMessage)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
}

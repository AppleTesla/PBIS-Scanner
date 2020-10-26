// MARK: Imports

import SwiftUI

// MARK: Views

struct JuvenileScrollView: View {

    @EnvironmentObject private var jvm: JuvenileManager

    var juveniles: [Juvenile]

    @State private var shouldConfirmDelete = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 15) {
                // Juvenile Icons
                ForEach(juveniles, id: \.id) { juvenile in
                    VStack {
                        ProfileIconView(badges: [.Juvenile(.online)])
                            .frame(width: 60, height: 60)
                            .contentShape(Circle())
                            .contextMenu {
                                Label("\(juvenile.first_name) \(juvenile.last_name)", systemImage: "person.fill")
                                Label("\(juvenile.points) points", systemImage: "number.square.fill")
                                Button(action: { }) {
                                    Label("Transaction History", systemImage: SystemImage.clock.rawValue)
                                }

                                Divider()

                                Menu("Delete \(juvenile.first_name)") {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.jvm.removeJuvenile(juvenile: juvenile)
                                        }
                                    }) {
                                        Label("Are You Sure?", image: SystemImage.trash.rawValue)
                                    }
                                }

                                Menu("Clear Queue") {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.jvm.removeAllJuveniles()
                                        }
                                    }) {
                                        Label("Are You Sure?", image: SystemImage.trash.rawValue)
                                    }
                                }
                            }
                        Text(juvenile.first_name)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 20)
        }
    }
}

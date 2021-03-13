// MARK: Imports

import SwiftUI

// MARK: Views

struct JuvenileScrollView: View {

    @EnvironmentObject private var jvm: JuvenileManager

    @State private var showHistory = false

    var juveniles: [Juvenile]

    @State private var shouldConfirmDelete = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center, spacing: 15) {
                // Juvenile Icons
                ForEach(juveniles, id: \.id) { juvenile in
                    VStack {
                        ProfileIconView(badges: [])
                            .frame(width: 60, height: 60)
                            .contentShape(Circle())
                            .contextMenu {
                                Label("\(juvenile.first_name) \(juvenile.last_name)", systemImage: "person.fill")
                                Label("\(juvenile.points) points", systemImage: "number.square.fill")
                                Button(action: { showHistory = true }) {
                                    Label("Transaction History", systemImage: SystemImage.clock.rawValue)
                                }

                                Divider()

                                Menu("Delete \(juvenile.first_name)") {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.jvm.removeJuvenile(juvenile: juvenile)
                                        }
                                    }) {
                                        Label("Are You Sure?", systemImage: SystemImage.trash.rawValue)
                                    }
                                }

                                Menu("Clear Queue") {
                                    Button(action: {
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                            self.jvm.removeAllJuveniles()
                                        }
                                    }) {
                                        Label("Are You Sure?", systemImage: SystemImage.trash.rawValue)
                                    }
                                }
                            }
                        Text(juvenile.first_name)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.vertical, 2)
                            .padding(.horizontal, 4)
                            .background(Color.gray)
                            .cornerRadius(3)
                    }
                    .sheet(isPresented: $showHistory) {
//                        TransactionView(juvenile: juvenile)
                    }
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 20)
        }
    }
}

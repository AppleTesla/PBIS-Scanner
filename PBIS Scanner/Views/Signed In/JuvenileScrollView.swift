// MARK: Imports

import SwiftUI

// MARK: Views

struct JuvenileScrollView: View {

    @EnvironmentObject private var jvm: JuvenileManager

    @Binding var juveniles: [Juvenile]

    @State private var shouldConfirmDelete = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center) {
                // Juvenile Icons
                ForEach(juveniles, id: \.id) { juvenile in
                    VStack {
                        ProfileIconView(badges: [.Juvenile(.online)])
                            .contextMenu {
                                Text("\(juvenile.first_name) \(juvenile.last_name)")
                                    .disabled(true)
                                Text("\(juvenile.points) points")
                                    .disabled(true)
                                Button(action: { }) {
                                    Image(.clock)
                                    Text("Transaction History")
                                }

                                Button(action: { self.jvm.removeJuvenile(juvenile: juvenile) }) {
                                    Image(.trash)
                                    Text("Remove \(juvenile.first_name) from queue")
                                }
                                .foregroundColor(.red)
                            }
                        Text(juvenile.first_name)
                    }
                }
                .padding(.horizontal, 5)
                // Delete All Button
                Button(action: {
                    self.shouldConfirmDelete = true
                }) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(Color.gray.opacity(0.25))
                        Image(.xmarkRectange)
                            .foregroundColor(Color.gray)
                            .font(.largeTitle)
                            .padding(.horizontal)
                    }
                    .aspectRatio(0.5, contentMode: .fit)
                    .opacity(self.jvm.juveniles.isEmpty ? 0 : 1)
                    .padding(.horizontal)
                }
                .alert(isPresented: self.$shouldConfirmDelete) {
                    Alert(title: Text("Are you sure?"),
                          primaryButton: .cancel(),
                          secondaryButton: .default(Text("Yes"), action: {
                            self.jvm.removeAllJuveniles()
                          }))
                }
                // Add New Button
                VStack {
                    Button(action: {

                    }) {

                        ProfileIconView(opacity: 0.2, customImage: .keyboard)
                            .frame(width: 50, height: 50)
                    }
                    .disabled(true)
                    Text("Add New")
                        .font(.footnote)
                }
                .hidden()
                .padding(.trailing)
            }
            .frame(height: 100)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: Imports

import SwiftUI

// MARK: Views

struct JuvenileScrollView: View {

    @EnvironmentObject private var jvm: JuvenileManager

    var juveniles: [Juvenile]

    @State private var shouldConfirmDelete = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .center) {
                // Juvenile Icons
                ForEach(juveniles, id: \.id) { juvenile in
                    VStack {
                        ProfileIconView(badges: [.Juvenile(.online)])
                            .frame(width: 60, height: 60)
                        Text(juvenile.first_name)
                    }
                    .padding(5)
                    .contextMenu {
                        Text("\(juvenile.first_name) \(juvenile.last_name)")
                            .disabled(true)
                        Text("\(juvenile.points) points")
                            .disabled(true)
                        Button(action: { }) {
                            Image(.clock)
                            Text("Transaction History")
                        }

                        Button(action: {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.jvm.removeJuvenile(juvenile: juvenile)
                            }
                        }) {
                            Image(.trash)
                            Text("Remove \(juvenile.first_name) from queue")
                        }
                        .foregroundColor(.red)
                    }
                }
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
                    .cornerRadius(5)
                    .padding(.horizontal, 5)
                }
                .alert(isPresented: self.$shouldConfirmDelete) {
                    Alert(title: Text("Are you sure?"),
                          primaryButton: .cancel(),
                          secondaryButton: .default(Text("Yes"), action: {
                            self.jvm.removeAllJuveniles()
                          }))
                }
            }
            .frame(height: 100)
            .padding(.horizontal, 20)
        }
    }
}

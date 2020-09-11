// MARK: Imports

import SwiftUI

// MARK: Views

struct BehaviorScrollView: View {

    @EnvironmentObject private var blm: BehaviorLocationManager

    @GestureState private var translation: CGFloat = 0
    @State private var cumulativeOffset: CGFloat = 0
    @State private var currentIndex: CGFloat = 0

    let cardWidth: CGFloat = 200
    let cardSpacing: CGFloat = 10

    var body: some View {
        let drag = DragGesture(minimumDistance: 0)
            .updating($translation, body: { (value, state, transaction) in
                state = value.translation.width
            })
            .onEnded { value in
                let finalIndex = self.blm.behaviors.count - 1
                let offset = value.translation.width / (self.cardWidth + self.cardSpacing / 2)
                self.currentIndex = max(min(self.currentIndex - offset.rounded(), CGFloat(finalIndex)), 0)
                self.cumulativeOffset = -(self.currentIndex) * (self.cardWidth + self.cardSpacing / 2)
        }

        return ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(blm.behaviors, id: \.id) { behavior in
                    GeometryReader { geo in
                        BehaviorCardView(behavior: behavior)
                            .padding(self.cardSpacing)
                            .blur(radius: abs(UIScreen.main.bounds.width/2 - geo.frame(in: .global).midX) / 150)
                            .rotation3DEffect(Angle(degrees: (Double(geo.frame(in: .global).maxX - UIScreen.main.bounds.width / 2 - self.cardWidth/2)) / -20),
                                              axis: (x: 0, y: 10, z: 0))
                            .onTapGesture {
                                self.blm.selectedBehavior = behavior
                                if let indexTo = self.blm.behaviors.firstIndex(of: behavior) {
                                    let distanceToGo = self.cardWidth + ( self.cardSpacing / 2)
                                    let offset = distanceToGo * (CGFloat(indexTo) - self.currentIndex)
                                    self.cumulativeOffset -= offset
                                    self.currentIndex = CGFloat(indexTo)
                                }
                        }
                    }
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: self.cardWidth, height: self.cardWidth)
                }
            }
            .frame(height: self.cardWidth + 20)
            .padding(.horizontal, UIScreen.main.bounds.width/2 - cardWidth/2)
            .offset(x: translation)
            .offset(x: cumulativeOffset)
            .animation(Animation.interpolatingSpring(stiffness: 300.0,
                                                     damping: 50.0,
                                                     initialVelocity: 30.0))
            .onReceive(blm.$behaviors) { _ in
                self.cumulativeOffset = 0
                self.currentIndex = 0
            }
            .simultaneousGesture(drag)
        }
    }
}

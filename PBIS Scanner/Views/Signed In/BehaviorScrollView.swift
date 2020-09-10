// MARK: Imports

import SwiftUI

// MARK: Views

struct BehaviorScrollView: View {

    @EnvironmentObject private var blm: BehaviorLocationManager

    let cardWidth: CGFloat = 200
    let spacing: CGFloat = 20

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(blm.behaviors.filter({
                    $0.category == blm.selectedCategory
                    && $0.location == blm.selectedLocation
                }), id: \.id) { behavior in
                    GeometryReader { geo in
                        BehaviorCardView(behavior: behavior)
                            .padding()
                            .blur(radius: abs(UIScreen.main.bounds.width/2 - geo.frame(in: .global).midX) / 200)
                            .rotation3DEffect(Angle(degrees: (Double(geo.frame(in: .global).maxX - UIScreen.main.bounds.width/2 - self.cardWidth/2)) / -20),
                                              axis: (x: 0, y: 10, z: 0))
                    }
                    .font(.system(size: 20, weight: .bold))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .minimumScaleFactor(0.5)
                    .aspectRatio(1, contentMode: .fit)
                    .frame(width: self.cardWidth, height: self.cardWidth)
                    .onTapGesture {
                        self.blm.selectedBehavior = behavior
                    }
                }
            }
            .frame(height: self.cardWidth)
            .padding(.horizontal, UIScreen.main.bounds.width/2 - cardWidth/2)
        }
    }
}

// MARK: Imports

import SwiftUI

// MARK: Views

struct BehaviorCardView: View {

    // MARK: Environment Objects

    @EnvironmentObject var uim: UIManager

    @EnvironmentObject var blm: BehaviorLocationManager

    // MARK: Properties

    let behavior: Behavior

    var body: some View {
        let themeColor = Color(uim.generateColorFor(text: behavior.title))

        return ZStack(alignment: .center) {
            Text(behavior.title)
                .foregroundColor(.white)
                .padding()
            VStack(alignment: .trailing) {
                Spacer()
                HStack {
                    Spacer()
                    if blm.selectedBehavior == self.behavior {
                        Image(.checkmarkCircleFill)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .mask(Circle())
                            .padding([.trailing, .bottom])
                    }
                }
            }
        }
        .background(
            Rectangle()
                .foregroundColor(.clear)
                .background(
                    LinearGradient(gradient: Gradient(colors: [themeColor, .purple]),
                                   startPoint: .topLeading,
                                   endPoint: .bottomTrailing)
            )
                .mask(RoundedRectangle(cornerRadius: 20, style: .continuous))
        )
        .overlay(
            ZStack {
                if blm.selectedBehavior == self.behavior {
                    RoundedRectangle(cornerRadius: 20)
                        .foregroundColor(Color.white.opacity(0.5))
                        .blur(radius: 20)
                        .mask(RoundedRectangle(cornerRadius: 20))
                }
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
            }
        )
            .scaleEffect(blm.selectedBehavior == self.behavior ? 1.2 : 1)
    }
}

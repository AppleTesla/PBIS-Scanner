// MARK: Imports

import SwiftUI

// MARK: Views

struct QueueDrawer<Content: View>: View {

    // MARK: Environment Objects

    @EnvironmentObject private var jvm: JuvenileManager

    @EnvironmentObject private var blm: BehaviorLocationManager

    // MARK: View Properties

    @State private var isMinimized = true

    // Minimizer Icon
    @State private var minOffset_HOR: CGFloat = 0
    @State private var minOffset_VER: CGFloat = 0

    // Category Preview
    @State private var categorySelectorSize: CGFloat = 1
    @State private var categorySelectorBGSize: CGFloat = 0

    let blurTintMix = 0.3

    let lowerDragThreshold: CGFloat = 200
    let upperDragThreshold: CGFloat = 300

    var content: () -> Content
    var body: some View {

        let minimizerDrag = DragGesture(minimumDistance: 0)
            .onChanged { value in
                self.minOffset_HOR = value.translation.width * 0.1
                self.minOffset_VER = value.translation.height * 0.1
                print("fgjdfgoijijuu777")
        }
        .onEnded { value in
            self.minOffset_HOR = 0
            self.minOffset_VER = 0
            if value.translation.height < -30 {
                self.isMinimized = false
            } else if value.translation.height > 30 {
                self.isMinimized = true
            }
        }

        let categoryDrag = DragGesture(minimumDistance: 0)
            .onChanged({ state in
                guard self.isMinimized else { return }
                if case 0 ..< self.lowerDragThreshold = abs(state.translation.height) { self.blm.selectedCategory = .safe }
                else if case self.lowerDragThreshold ..< self.upperDragThreshold = abs(state.translation.height) { self.blm.selectedCategory = .responsible }
                else if case self.upperDragThreshold... = abs(state.translation.height) { self.blm.selectedCategory = .considerate }

                self.categorySelectorSize = abs(state.translation.height / -UIScreen.main.bounds.height / 2) + 1

                if state.translation.height < 0 {
                    if abs(state.translation.height) > self.upperDragThreshold {
                        self.categorySelectorBGSize = state.translation.height * 2.2 - (state.translation.height + self.upperDragThreshold)
                    } else {
                        self.categorySelectorBGSize = state.translation.height * 2.2
                    }
                }
            })
            .onEnded { _ in
                self.categorySelectorSize = 0
                self.categorySelectorBGSize = 0
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { self.categorySelectorSize = 1 }
                UINotificationFeedbackGenerator().notificationOccurred(.success)
        }

        return ZStack(alignment: .bottom) {

            // MARK: Category Dragger

            ZStack(alignment: .topLeading) {
                Rectangle()
                    .foregroundColor(.orange)
                    .opacity(0.5)
                Text(blm.selectedCategory.stringValue.uppercased())
                    .foregroundColor(.white)
                    .font(.system(size: 30, weight: .black, design: Font.Design.monospaced))
                    .padding([.top, .leading])
                    .animation(nil)
            }
            .position(x: UIScreen.main.bounds.width/2)
            .frame(height: categorySelectorBGSize)
            .opacity(categorySelectorBGSize == 0 ? 0 : 1)
            .disabled(categorySelectorBGSize == 0)

            // MARK: Queue Drawer

            VStack {
                Rectangle().frame(height: 0.5).foregroundColor(.gray).opacity(0.5)

                // MARK: Mini Bar - BEGIN

                HStack(alignment: .top, spacing: 15) {
                    // MARK: Mini Bar - Category Prefix
                    BoxStringContainerView(text: String(blm.selectedCategory.stringValue.prefix(1)))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(width: isMinimized ? 40 : 50)
                        .scaleEffect(categorySelectorSize, anchor: .center)
                        .font(.system(size: isMinimized ? 20 : 30))
                        .onTapGesture {
                            let currentCategory = self.blm.selectedCategory
                            self.blm.selectedCategory = currentCategory.next(state: currentCategory)
                    }
                        .gesture(categoryDrag)
                        .onReceive(blm.$selectedCategory) { _ in
                            if self.blm.selectedCategory != self.blm.selectedCategory_PREV {
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                    }

                    // MARK: Mini Bar - Behavior & Queue Count Preview

                    VStack(alignment: .leading, spacing: 4) {
                        Text(blm.selectedBehavior?.title ?? "No behavior selected")
                            .fontWeight(.medium)
                            .opacity(blm.selectedBehavior?.title == nil ? 0.2 : 1)
                        if !jvm.queueVerbalUpdate.isEmpty {
                            Text(jvm.queueVerbalUpdate)
                                .foregroundColor(.gray)
                                .onReceive(jvm.$queueVerbalUpdate.removeDuplicates()) { _ in
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        self.jvm.queueVerbalUpdate = ""
                                    }
                            }
                        }
                    }
                    .animation(nil)

                    Spacer()

                    // MARK: Mini Bar - Toggle Minimize

                    VStack(alignment: .trailing) {
                        Image(isMinimized ? .chevronUpSquare : .chevronDownSquareFill)
                            .resizable()
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 30)
                            .padding(isMinimized ? .bottom : .vertical)
                            .opacity(0.5)
                            .offset(x: minOffset_HOR, y: minOffset_VER)
                            .onTapGesture { self.isMinimized.toggle() }
                    }
                }
                .padding([.top, .horizontal])
                .padding(.bottom, !jvm.juveniles.isEmpty && blm.selectedBehavior != nil ? 0 : isMinimized ? 40 : 0)
                .contentShape(Rectangle())
                .gesture(minimizerDrag)

                // MARK: Mini Bar - END

                // MARK: Submit Button

                if !jvm.juveniles.isEmpty && blm.selectedBehavior != nil {
                    Button(action: {
                        self.jvm.saveToBucket(with: self.blm.selectedBehavior, for: self.jvm.juveniles)
                    }) {
                        Text("Submit (\(jvm.juveniles.count))")
                            .fontWeight(.medium)
                            .padding()
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal, 5)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, isMinimized ? 40 : 5)
                }

                // MARK: Queue Drawer - Below Mini-Bar

                ScrollView(.vertical, showsIndicators: false) {
                    VStack {
                        Divider()

                        // MARK: Queue Drawer - Behavior Selector Placeholder

                        Group {
                            if blm.selectedBehavior == nil {
                                VStack {
                                    Text("Hey there!")
                                        .fontWeight(.bold)
                                        .padding()
                                    Text("Pull down from the location box up top 👆")
                                        .foregroundColor(.gray)
                                        .padding(.bottom)
                                }
                            } else {

                                // MARK: Queue Drawer - Behavior Selector

                                BehaviorScrollView()
                                    .padding(.vertical)
                                    .shadow(radius: 25)
                            }
                        }

                        Divider()

                        // MARK: Queue Drawer - Juvenile Selector

                        JuvenileScrollView(juveniles: self.jvm.juveniles)
                        Divider()

                        // MARK: Queue Drawer - Content Generic

                        self.content()
                        Spacer()
                    }
                }
                .opacity(isMinimized ? 0 : 1)
                .disabled(isMinimized)
                .frame(width: nil, height: isMinimized ? 0 : nil, alignment: .bottom)
            }
            .background(

                // MARK: Queue Drawer - Blur Background

                ZStack {
                    Color(UIColor(named: "DrawerBG_Tint")!)
                        .opacity(blurTintMix)
                    VisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
                }
            )
                .cornerRadius(radius: isMinimized ? 0 : 10, corners: [.topLeft, .topRight])
        }
        .animation(Animation.interpolatingSpring(stiffness: 300.0,
                                                    damping: 30.0,
                                                    initialVelocity: 10.0))
    }
}

//
//  BlurView.swift
//  PBIS Scanner
//
//  Created by Jaron Schreiber on 8/31/20.
//  Copyright © 2020 DxHub. All rights reserved.
//

import SwiftUI

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}

struct BlurView_Previews: PreviewProvider {
    static var previews: some View {
        VisualEffectView()
    }
}

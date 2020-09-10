//
//  BoxCounterView.swift
//  PBIS Scanner
//
//  Created by Jaron Schreiber on 8/31/20.
//  Copyright © 2020 DxHub. All rights reserved.
//

import SwiftUI

struct BoxStringContainerView: View {
    @Binding var text: String
    var body: some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 5)
                .foregroundColor(.red)
            Text(String(juveniles.count))
                .foregroundColor(.white)
                .fontWeight(.bold)
        }
    }
}

struct BoxCounterView_Previews: PreviewProvider {
    static var previews: some View {
        BoxStringContainerView(juveniles: .constant([]))
    }
}

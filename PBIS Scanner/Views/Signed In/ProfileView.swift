//
//  ProfileView.swift
//  PBIS Scanner
//
//  Created by Jaron Schreiber on 8/29/20.
//  Copyright © 2020 DxHub. All rights reserved.
//

import SwiftUI

struct ProfileView: View {

    // MARK: Properties

    @EnvironmentObject private var auth: AuthManager

    var body: some View {
        Button(action: {
            self.auth.signOut()
        }, label: {
            Text("Sign Out")
        })
            .padding()
            .background(Color.purple)
            .cornerRadius(5)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}

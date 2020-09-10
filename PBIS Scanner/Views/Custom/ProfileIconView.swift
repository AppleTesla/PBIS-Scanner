// MARK: Imports

import SwiftUI

// MARK: Views

struct ProfileIconView: View {
    
    var badges: [Badge] = []

    var opacity: Double = 1

    var customImage: SystemImage = .personFill

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Image(customImage)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30)
                .padding()
                .foregroundColor(.white)
                .background(Color.gray.opacity(opacity))
                .mask(Circle())
            HStack {
                ForEach(badges, id: \.self) { badge in
                    Image(badge.image)
                        .font(.system(size: 20))
                        .padding(5)
                        .foregroundColor(.white)
                        .background(Color.green)
                        .mask(Circle())
                }
            }
        }
    }
}

struct ProfileIconView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileIconView(badges: [.Juvenile(.online)])
    }
}

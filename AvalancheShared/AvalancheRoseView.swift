import SwiftUI

public struct AvalancheRoseView: View {
    let avalancheData: AvalancheData
    
    public init(avalancheData: AvalancheData) {
        self.avalancheData = avalancheData
    }
    
    public var body: some View {
        GeometryReader { geometry in
            if let url = URL(string: "https://utahavalanchecenter.org/" + avalancheData.overallDangerRoseImage) {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                } placeholder: {
                    ProgressView()
                }
                .padding(5)
            } else {
                Text("Unable to load rose")
            }
        }
    }
}

struct AvalancheRoseView_Previews: PreviewProvider {
    static var previews: some View {
        AvalancheRoseView(avalancheData: .placeholder)
            .frame(width: 200, height: 200)
    }
}
//
//  CoinListItem.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import SwiftUI

extension Formatter {
    static let number = NumberFormatter()
}
extension Numeric {
    func formatted(with groupingSeparator: String? = nil, style: NumberFormatter.Style) -> String {
        Formatter.number.numberStyle = style
        if let groupingSeparator = groupingSeparator {
            Formatter.number.groupingSeparator = groupingSeparator
        }
        return Formatter.number.string(for: self) ?? ""
    }
    // Localized
    var currency:   String { formatted(style: .currency) }

}

struct CoinListItem: View {
    @EnvironmentObject var modelData: ModelData
    var index: Int

    @ObservedObject var imageLoader:ImageLoader
    @State var image:UIImage = UIImage()
    
    init(index: Int, url: String) {
        self.index = index
        imageLoader = ImageLoader(urlString:url)
    }
    
    var body: some View {
        
        let columns: [GridItem] = [
            GridItem(.flexible(minimum: 170), spacing: -50, alignment: .leading),
            GridItem(.flexible(), spacing: -50),
            GridItem(.flexible(), alignment: .trailing)
        ]
        VStack {
            LazyVGrid(
                columns: columns
            ) {
                HStack {
                    Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:50, height:50)
                                    .onReceive(imageLoader.didChange) { data in
                                    self.image = UIImage(data: data) ?? UIImage()
                                }
                    Text(modelData.coins[index].name)
                        .font(.title2)
                        .foregroundColor(Color.accentColor)
                        .bold()
                }
                Text(String(NumberFormatter.localizedString(from: NSNumber(value: modelData.coins[index].quantity), number: NumberFormatter.Style.decimal)))
                    .font(.title3)
                Text((modelData.coins[index].value * modelData.coins[index].quantity).currency)
                    .font(.title3)
            }
            HStack {
                Spacer()
                Text(String(modelData.coins[index].quantity) + " x " + String(modelData.coins[index].value.currency))
                    .font(.footnote)
                }
        }
    }
}

struct CoinListItem_Previews: PreviewProvider {
    static var previews: some View {
        CoinListItem(index: 0, url: "https://g.foolcdn.com/misc-assets/logo-tmf-primary-8-purple-blue.svg")
            .environmentObject(ModelData())
    }
}

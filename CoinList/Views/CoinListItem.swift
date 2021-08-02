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
    var coin: Coin

    @ObservedObject var imageLoader:ImageLoader
    @State private var image:UIImage = UIImage()
    
    init(coin: Coin) {
        self.coin = coin
        imageLoader = ImageLoader(urlString: coin.imageUrl)
    }
    
    var body: some View {
        
        let columns: [GridItem] = [
            GridItem(.flexible(minimum: 160), spacing: -10, alignment: .leading),
            GridItem(.flexible(), spacing: -50, alignment: .leading),
            GridItem(.flexible(), alignment: .trailing)
        ]
        
        LazyVGrid(
            columns: columns
        ) {
            HStack(spacing: 0)
            {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width:25, height:25)
                    .onReceive(imageLoader.didChange) { data in
                    self.image = UIImage(data: data) ?? UIImage()
                    }
                    .padding(.trailing, 5.0)
                Text(coin.name)
                    .font(.body)
            }
            Text(String(NumberFormatter.localizedString(from: NSNumber(value: coin.quantity), number: NumberFormatter.Style.decimal)))
                .font(.body)
            VStack (alignment: .trailing, spacing: 5){
                Text((coin.value * coin.quantity).currency)
                    .font(.body.weight(.heavy))
                    .animation(.easeInOut)
                Text(String(coin.quantity) + " x " + String(coin.value.currency))
                    .font(.caption2)
            }
        }
        .listRowBackground(Color.accentColor)
    }
}

struct CoinListItem_Previews: PreviewProvider {
    static var previews: some View {
        CoinListItem(coin: Coin())
    }
}

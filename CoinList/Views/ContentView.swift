//
//  ContentView.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        List {
            VStack {
                HStack {
                    Text("List of Cryptos")
                        .font(.title)
                    Spacer()
                    Button(action: {
                        modelData.update()
                    }) {
                        Text("Update")
                            .font(.body)
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(10)
                    .buttonStyle(BorderlessButtonStyle())
                }
                HStack {
                    Text("Crypto")
                        .font(.headline)
                    Spacer()
                    Text("Quantity")
                        .font(.headline)
                    Spacer()
                    Text("Value")
                        .font(.headline)
                }
                .padding()
            }
            ForEach(0 ..< modelData.coins.count) { index in
                CoinListItem(index: index, url: modelData.coins[index].imageUrl)
                    .environmentObject(modelData)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}

//
//  ContentView.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import SwiftUI


extension View {
    /// Applies the given transform if the given condition evaluates to `true`.
    /// - Parameters:
    ///   - condition: The condition to evaluate.
    ///   - transform: The transform to apply to the source `View`.
    /// - Returns: Either the original `View` or the modified `View` if the condition is `true`.
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var modelData: ModelData
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text("Gambling is fun!")
                        .font(.title)
                        .bold()
                    Spacer()
                    if (modelData.working) {
                        ProgressView()
                            .padding(.trailing, 1.0)
                    }
                    Button(action: {
                        modelData.updateCoinList()
                    }) {
                        if (modelData.working) {
                            Text("Working...")
                            .font(.body)
                        }
                        else {
                            Text("Update")
                            .font(.body)
                        }
                    }
                    .padding(.horizontal, 10.0)
                    .padding(.vertical, 5.0)
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .buttonStyle(BorderlessButtonStyle())
                    .disabled(modelData.working)
                }.padding(.vertical)
                HStack {
                    Text("Coin")
                        .font(.headline)
                    Spacer()
                    Text("Quantity")
                        .font(.headline)
                    Spacer()
                    Text("Value")
                        .font(.headline)
                }.padding([.top, .leading, .trailing])
                
                //List {
                ScrollView {
                    Spacer()
                    if !modelData.error {
                    ForEach(modelData.coins, id: \.id) { coin in
                        CoinListItem(coin: coin)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.7)))
                        Divider()
                            .background(Color.accentColor)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.7)))
                    }
                        HStack(spacing: 0) {
                            Spacer()
                            Text("Total: \(modelData.getTotal().currency)")
                                .font(.title2)
                                .bold()
                                .animation(.easeInOut)
                        }
                    }
                    else {
                        Spacer()
                        Spacer()
                        Spacer()
                        Text("Can't parse JSON file")
                            .foregroundColor(.red)
                            .animation(.easeInOut)
                    }
                }
                .padding(5.0)
            }.padding(.horizontal)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(ModelData())
    }
}

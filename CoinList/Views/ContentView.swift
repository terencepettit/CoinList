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
                        modelData.update()
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
                }.padding()
                
                //List {
                    ForEach(0 ..< modelData.coins.count) { index in
                    CoinListItem(index: index, url: modelData.coins[index].imageUrl)
                        .environmentObject(modelData)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 5)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                
                Text("USD total: \(modelData.getTotal().currency)")
                    .font(.headline)
                    .animation(.easeInOut)
                    .padding()
                Spacer()
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

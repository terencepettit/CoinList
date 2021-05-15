//
//  CoinListApp.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-10.
//

import SwiftUI

@main
struct CoinListApp: App {
    @StateObject private var modelData = ModelData()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(modelData)
        }
    }
}

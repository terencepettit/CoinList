//
//  LoadingIcon.swift
//  CoinList
//
//  Created by Terence Pettit on 2021-05-15.
//

import SwiftUI

struct LoadingIcon: View {
    private var columns: [GridItem] = [
        GridItem(.fixed(100), spacing: 0),
        GridItem(.fixed(100), spacing: 16),
        GridItem(.fixed(100), spacing: 16),
        GridItem(.fixed(100), spacing: 16),
        GridItem(.fixed(100), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(
                columns: columns,
                alignment: .center,
                spacing: 16,
                pinnedViews: [.sectionHeaders, .sectionFooters]
            ) {
                Section(header: Text("Section 1").font(.title)) {
                    ForEach(0...10, id: \.self) { index in
                        
                            Text("hey \(index) lalalal")
                    }
                }


                    ForEach(11...20, id: \.self) { index in
                        
                            Text("hey \(index) lalalal")
                }
            }
        }
    }

}

struct LoadingIcon_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIcon()
    }
}

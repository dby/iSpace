//
//  AlbumContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI

struct AlbumContentView: View {
    var body: some View {
        ScrollView {
            VStack {
                Spacer()
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                    ForEach(0 ..< 5){ index in
                        Section(header: Text("Header \(index)")
                            .bold()
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white),
                                footer: Text("Footer \(index)")
                            .bold()
                            .font(.title)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white)
                        ) {
                            ForEach(0 ..< 20) { idx in
                                RoundedRectangle(cornerRadius: 5)
                                    .foregroundColor(Color(hue: 0.03 * Double(index * 10 + idx) , saturation: 1, brightness: 1))
                                    .frame(height: 50)
                                    .overlay(Text("\(index * 10 + idx)"))
                            }
                        }
                    }
                }
            }
        }
    }
}

struct AlbumContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumContentView()
    }
}

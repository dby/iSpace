//
//  AboutUsView.swift
//  iSecrets
//
//  Created by dby on 2023/7/29.
//

import SwiftUI

struct AboutUsView: View {
    var body: some View {
        NavigationView {
            ScrollView {
                Text("AboutUSDesc".localized())
                    .foregroundColor(Color(uiColor: iColor.secondary))
                    .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                    .multilineTextAlignment(.leading)
            }
        }
        .navigationTitle("About Us".localized())
        .toolbar(.hidden, for: .tabBar)
    }
}

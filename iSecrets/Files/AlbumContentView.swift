//
//  AlbumContentView.swift
//  iSecrets
//
//  Created by dby on 2023/6/11.
//

import SwiftUI
import JFHeroBrowser

let keyWindow = UIApplication.shared.connectedScenes
                        .map({ $0 as? UIWindowScene })
                        .compactMap({ $0 })
                        .first?.windows.first

let myAppRootVC : UIViewController? = keyWindow?.rootViewController

let origins: [UIImage] = {
    var temp: [UIImage] = []
    for i in 1...20 {
        temp.append(UIImage(named: "pwd_uninput")!)
    }
    return temp
}()

struct AlbumContentView: View {
    @State var columns = [
        GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
//        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns) {
                    ForEach(1..<origins.count, id:\.self) { index in
                        ImageCell(index: index).frame(height: columns.count == 1 ? 300 : 150).onTapGesture {
                            var list: [HeroBrowserViewModule] = []
                            for i in 0..<origins.count {
                                list.append(HeroBrowserLocalImageViewModule(image: origins[i]))
                            }
                            myAppRootVC?.hero.browserPhoto(viewModules: list, initIndex: index)
                        }
                    }
                }
            }
//            .navigationBarTitle(Text("SwiftUI Example"))
//        }
    }
}

struct AlbumContentView_Previews: PreviewProvider {
    static var previews: some View {
        AlbumContentView()
    }
}

struct ImageCell: View {
    var alreadyCached: Bool {
//        ImageCache.default.isCached(forKey: url.absoluteString)
        true
    }

    let index: Int
    var image: UIImage {
        origins[index]
    }

    var body: some View {
        HStack(alignment: .center) {
            Spacer()
//            KFImage.url(url)
//                .resizable()
//                .onSuccess { r in
//                    print("Success: \(self.index) - \(r.cacheType)")
//                }
//                .onFailure { e in
//                    print("Error \(self.index): \(e)")
//                }
//                .onProgress { downloaded, total in
//                    print("\(downloaded) / \(total))")
//                }
//                .placeholder {
//                    HStack {
//                        Image(systemName: "arrow.2.circlepath.circle")
//                            .resizable()
//                            .frame(width: 50, height: 50)
//                            .padding(10)
//                        Text("Loading...").font(.title)
//                    }
//                    .foregroundColor(.gray)
//                }
//
//                .cornerRadius(20)

            Image(uiImage: image)
            
            Spacer()
        }.padding(.vertical, 12)
    }

}

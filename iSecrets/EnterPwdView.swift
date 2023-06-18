//
//  EnterPwdView.swift
//  iSecrets
//
//  Created by dby on 2023/6/14.
//

import SwiftUI

struct EnterPwdView: View {
    let data = ["1", "2" , "3", "4", "5", "6", "7", "8", "9", "DEL", "0", "OK"]
    let threeGridItem = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    let sixGridItem = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
    ]
    
    @State private var inputStep: Int = 0
    @State private var pwdStr: String = ""
    
    var body: some View {
        VStack {
            Text("iSecret")
                .font(.largeTitle)
            
            LazyVGrid(columns: sixGridItem) {
                ForEach(0 ..< 6) { index in
                    index >= inputStep ? Image("pwd_uninput") : Image("pwd_inputed")
                }
            }.frame(width: 200)
            
            LazyVGrid(columns: threeGridItem) {
                ForEach(data, id: \.self){ item in
                    Circle()
                        .foregroundColor(Color(.tertiarySystemGroupedBackground))
                        .frame(height: 80)
                        .overlay(
                            Text("\(item)")
                                .font(.title)
                        ).onTapGesture {
                            self.inputStep = self.inputStep + 1
                            switch item {
                            case "1":
                                pwdStr.append("1")
                            case "2":
                                pwdStr.append("2")
                            case "3":
                                pwdStr.append("3")
                            case "4":
                                pwdStr.append("4")
                            case "5":
                                pwdStr.append("5")
                            case "6":
                                pwdStr.append("6")
                            case "7":
                                pwdStr.append("7")
                            case "8":
                                pwdStr.append("8")
                            case "9":
                                pwdStr.append("9")
                                break
                            case "DEL":
                                break
                            case "0":
                                pwdStr.append("0")
                            case "OK":
                                print("pwd: \(pwdStr)")
                            default:
                                break
                            }
                        }
                }
            }.padding(EdgeInsets(top: 50, leading: 30, bottom: 0, trailing: 30))
        }
    }
}

struct EnterPwdView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPwdView()
    }
}
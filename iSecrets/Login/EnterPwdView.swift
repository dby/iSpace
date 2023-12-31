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
    @State private var hint: String = "Please set the lock screen password".localized()
    @State private var offset = CGSize.zero
    
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var viewModel: EnterPwdViewModel
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        VStack {
            Text("iSpace")
                .font(.system(size: 50))
                .bold()
                .overlayMask(
                    LinearGradient(colors: [Color(uiColor: iColor.tertiary), Color(uiColor: iColor.primary)],
                                   startPoint: .leading,
                                   endPoint: .trailing)
                )
            
            Spacer().frame(height: 35)
            
            Text(hint)
                .font(Font.system(size: 18))
                .foregroundColor(Color(uiColor: iColor.primary))
            
            Spacer().frame(height:30)
            
            LazyVGrid(columns: sixGridItem) {
                ForEach(0 ..< 6) { index in
                    if index >= inputStep {
                        Image("pwd_uninput")
                            .foregroundColor(Color(uiColor: iColor.secondary))
                            .offset(x: offset.width, y: 0)
                            .animation(.easeIn, value: 0.5)
                    } else {
                        Image("pwd_inputed")
                            .foregroundColor(Color(uiColor: iColor.secondary))
                            .offset(x: offset.width, y: 0)
                            .animation(.easeIn, value: 0.5)
                    }
                }
            }
            .frame(width: 200, height: 20)
            
            LazyVGrid(columns: threeGridItem) {
                ForEach(data, id: \.self){ item in
                    Circle()
                        .foregroundColor(Color(.tertiarySystemGroupedBackground))
                        .frame(height: 80)
                        .overlay(
                            Text("\(item)")
                                .foregroundColor(Color(uiColor: iColor.secondary))
                                .font(item.count == 1 ? .title : .title2)
                                .bold()
                        ).onTapGesture {
                            self.inputStep = self.inputStep + 1
                            switch item {
                            case "0":
                                pwdStr.append("0")
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
                            case "DEL":
                                if pwdStr.count >= 1 {
                                    pwdStr.removeLast()
                                    self.inputStep = self.inputStep - 2
                                } else {
                                    pwdStr = ""
                                    self.inputStep = 0
                                }
                            case "OK":
                                self.inputStep = self.inputStep - 1
                                print("pwd: \(pwdStr)")
                            default:
                                break
                            }
                            
                            if pwdStr.count >= 6 {
                                viewModel.tryLoginOrRegister(pwdStr)
                                
                                if (viewModel.state == .registerSetpOne || viewModel.state == .chgPwdStepOne) {
                                    hint = "Please set a password".localized()
                                    pwdStr = ""
                                    inputStep = 0
                                } else if (viewModel.state == .registerSetpTwo || viewModel.state == .chgPwdStepTwo) {
                                    hint = "Please make sure the password".localized()
                                    pwdStr = ""
                                    inputStep = 0
                                } else if (viewModel.state == .registerSucceed || viewModel.state == .chgPwdSucceed) {                                    
                                    self.presentationMode.wrappedValue.dismiss()
                                    homeCoordinator.toast(viewModel.state == .registerSucceed ? "Registration Success".localized() : "Password has been updated".localized())
                                    homeCoordinator.refreshDirsIfNeed()
                                } else if (viewModel.state == .registerFailed || viewModel.state == .chgPwdFailed) {
                                    pwdStr = ""
                                    inputStep = 0
                                    
                                    viewModel.state = (viewModel.state == .registerFailed ? .registerSetpOne : .chgPwdStepOne)
                                    hint = viewModel.prompt
                                    
                                    withAnimation(Animation.linear(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                        if (self.offset.width == 0 || self.offset.width == 2) {
                                            self.offset = CGSize(width: -2, height: 0)
                                        } else {
                                            self.offset = CGSize(width: 2, height: 0)
                                        }
                                    }
                                } else if viewModel.state == .loginSucceed {
                                    self.presentationMode.wrappedValue.dismiss()
                                    homeCoordinator.toast("Login Successful".localized())
                                    homeCoordinator.refreshDirsIfNeed()
                                } else if viewModel.state == .loginFailed {
                                    pwdStr = ""
                                    inputStep = 0
                                    
                                    viewModel.state = .login
                                    
                                    withAnimation(Animation.linear(duration: 0.1).repeatCount(3, autoreverses: true)) {
                                        if (self.offset.width == 0 || self.offset.width == 2) {
                                            self.offset = CGSize(width: -2, height: 0)
                                        } else {
                                            self.offset = CGSize(width: 2, height: 0)
                                        }
                                    }
                                }
                            }
                        }
                }
            }
            .padding(EdgeInsets(top: 50, leading: 30, bottom: 0, trailing: 30))
        }.onAppear(perform: {
            if core.account.0 == .notLogin {
                hint = "Please enter the lock screen password".localized()
            } else if core.account.0 == .notCreate {
                hint = "Please set a password".localized()
            }
        })
    }
}

//struct EnterPwdView_Previews: PreviewProvider {
//    static var previews: some View {
//        EnterPwdView()
//    }
//}

//
//  GuiseContentView.swift
//  iSecrets
//
//  Created by dby on 2023/8/6.
//

import SwiftUI

struct GuiseContentView: View {
    @State private var isOn: Bool = Settings.isOpenFakeSpace
    @State private var isShowingAlert: Bool = false
    @State private var newPwd: String = ""
    @State private var bJumpToEnterPwdView: Bool = false
    
    @EnvironmentObject var homeCoordinator: HomeCoordinator
    
    var body: some View {
        VStack {
            Spacer()
            
            Text("Enter the camouflage password to enter the camouflage space, and others cannot view the privacy space of the main space".localized())
                .font(Font.system(size: 18))
                .lineSpacing(10)
                .frame(height:100)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .multilineTextAlignment(.leading)
            
            List {
                HStack {
                    Text("Open the camouflage space immediately".localized())
                    Spacer()
                
                    Toggle(isOn: $isOn) {}
                    .frame(height: 40)
                    .background(Color.clear)
                    .alert("Please enter the main space password".localized(), isPresented: $isShowingAlert) {
                        TextField("Please enter the main space password".localized(), text: $newPwd)
                            .keyboardType(.numberPad)
                            .onChange(of: newPwd) { newValue in
                                newPwd = String(newPwd.prefix(6))
                            }
                        Button("Cancel") {
                            isOn = false
                        }
                        Button("OK") {
                            if newPwd == core.secretDB.getMainSpaceAccount()?.pwd {
                                bJumpToEnterPwdView = true
                            } else {
                                homeCoordinator.toast("Enter password error".localized())
                                isOn = false
                            }
                            
                            newPwd = ""
                        }
                    }
                    .onTapGesture {
                        if (core.secretDB.getFakeSpaceAccount().count > 0) {
                            print("toggle isOpenFakeSpace to \(!isOn)")
                            Settings.isOpenFakeSpace = !isOn
                            newPwd = ""
                        } else if (newPwd == core.secretDB.getMainSpaceAccount()?.pwd) {
                            // 新密码 == 主空间密码
                            homeCoordinator.toast("The camouflage password cannot be consistent with the main space password".localized())
                            newPwd = ""
                        } else {
                            // 创建伪装空间
                            isShowingAlert = true
                        }
                    }
                }
            }
            .onAppear(perform: {
                isOn = Settings.isOpenFakeSpace
            })
            .navigationTitle("Fake Space".localized())
            .fullScreenCover(isPresented: $bJumpToEnterPwdView, content: {
                EnterPwdView(viewModel: EnterPwdViewModel(state: .registerSetpOne, modifiedMainSpace: false))
            })
        }.background(Color(uiColor: UIColor.systemGroupedBackground))
    }
}

struct GuiseContentView_Previews: PreviewProvider {
    static var previews: some View {
        GuiseContentView()
    }
}

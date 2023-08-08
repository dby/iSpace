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
            
            Text("输入伪装密码可以进入伪装空间，别人无法查看主空间的隐私空间")
                .font(Font.system(size: 18))
                .lineSpacing(10)
                .frame(height:100)
                .padding(EdgeInsets(top: 0, leading: 20, bottom: 20, trailing: 20))
                .multilineTextAlignment(.leading)
            
            List {
                HStack {
                    Text("立即开启伪装空间")
                    Spacer()
                
                    Toggle(isOn: $isOn) {}
                    .frame(height: 40)
                    .background(Color.clear)
                    .alert("请输入主空间密码", isPresented: $isShowingAlert) {
                        TextField("请输入主空间密码", text: $newPwd)
                        .onChange(of: newPwd) { newValue in
                            newPwd = String(newPwd.prefix(6))
                        }
                        Button("Cancel") {
                            
                        }
                        Button("OK") {
                            if newPwd == core.secretDB.getMainSpaceAccount()?.pwd {
                                bJumpToEnterPwdView = true
                            } else {
                                homeCoordinator.toast("密码输入错误")
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
                            homeCoordinator.toast( "伪装空间密码不能与主空间密码一致")
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
            .navigationTitle("伪装空间")
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

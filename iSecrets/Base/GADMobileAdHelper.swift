//
//  GADMobileAdHelper.swift
//  iSecrets
//
//  Created by dby on 2023/8/15.
//

import Foundation
import GoogleMobileAds

let gGADMobileAdHelper = GADMobileAdHelper()

class GADMobileAdHelper: NSObject {
    
    //MARK: - Variables
    private var tag: String = ""
    private var rewardedAd: GADRewardedAd?
    /// 播放完激励视频之后，需要执行的任务
    private var pendingBlock: (() -> Void)?
}

//MARK: - Function
extension GADMobileAdHelper {
    /// 预加载"视频激励广告"
    func preloadGADRewardVieoAd() {
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ GADSimulatorID ]
        
        let request = GADRequest()
        GADRewardedAd.load(withAdUnitID:"ca-app-pub-3940256099942544/1712485313",
                           request: request,
                           completionHandler: { [self] ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                self.rewardedAd = nil
                return
            }
            
            rewardedAd = ad
            print("Rewarded ad loaded.")
            rewardedAd?.fullScreenContentDelegate = self
        })
    }
    
    /**
     * 按需展示激励广告
     */
    func showGoogleMobileAdsIfNeed(tag: String, pendingBlock: (() -> Void)?) {
//        Global.opNumMayLeadAds = Global.opNumMayLeadAds + 1
//        if (Global.opNumMayLeadAds > OpMaxNumToLeadAds) {
//            Global.opNumMayLeadAds = 0
            
            //触发激励广告
            show(tag: tag, pendingBlock: pendingBlock)
//        } else {
//            pendingBlock?()
//        }
    }
    
    func show(tag: String, pendingBlock: (() -> Void)?) {
        guard
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let rootVC = windowScene.windows.first?.rootViewController else
        {
            return
        }
        
        self.tag = tag
        self.pendingBlock = pendingBlock
        
        if let ad = rewardedAd {
            ad.present(fromRootViewController: rootVC) {
                let reward = ad.adReward
                print("Reward received with currency \(reward.amount), amount \(reward.amount.doubleValue)")
                // TODO: Reward the user.
                // 此时激励视频已经播放完了，可以给用户播放奖励
            }
        } else {
            print("Ad wasn't ready")
            self.preloadGADRewardVieoAd()
            self.pendingBlock?()
            self.pendingBlock = nil
        }
    }
}

//MARK: - Google Ads -
extension GADMobileAdHelper: GADFullScreenContentDelegate {
    /// Tells the delegate that the ad failed to present full screen content.
    func ad(_ ad: GADFullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("Ad did fail to present full screen content. \(error.localizedDescription)")
        self.preloadGADRewardVieoAd()
    }
    
    /// Tells the delegate that the ad will present full screen content.
    func adWillPresentFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad will present full screen content.")
    }
    
    /// Tells the delegate that the ad dismissed full screen content.
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        print("Ad did dismiss full screen content.")
        self.preloadGADRewardVieoAd()
        self.pendingBlock?()
        self.pendingBlock = nil
    }
}

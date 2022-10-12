//
//  StandardGitMartActionHandler.swift
//  
//
//  Created by Zachary Shakked on 10/4/22.
//

import UIKit
import SafariServices
import StoreKit

public class StandardGitMartActionHandler {
    public static func handleAction(library: GitMartLibrary.Type, action: GitMartAction, controller: UIViewController?) {
        switch action {
        case .purchaseProduct(_):
            break
        case .restorePurchases:
            break
        case .openURL(let url, let withSafari):
            if withSafari {
                let sfvc = SFSafariViewController(url: url)
                controller?.present(sfvc, animated: true)
            } else {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url)
                }
            }
        case .requestRating:
            if let windowScence = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: windowScence)
            }
        case .requestWrittenReview:
            let url = URL(string: "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=\(GitMart.shared.appID)&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")!
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
            }
        case .contactSupport:
            break
        default:
            break
        }
    }
}

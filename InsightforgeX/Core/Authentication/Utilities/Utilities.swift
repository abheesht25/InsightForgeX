//
//  Utilities.swift
//  InsightforgeX
//
//  Created by Srivastava, Abhisht on 24/03/24.
//

import Foundation
import UIKit

final class Utilities {
    static let shared = Utilities()
    
    private init() {}
    
    @MainActor
    class func topViewController(controller: UIViewController? = nil) -> UIViewController? {
        
        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
        if let navigationController = controller as? UINavigationController{
            return topViewController(controller: navigationController.visibleViewController)
        }
        
        if let tabController = controller as? UITabBarController{
            if let selected = tabController.selectedViewController{
                return topViewController(controller: selected)
            }
        }
        
        if let presented = controller?.presentedViewController{
            return topViewController(controller: presented)
        }
        return controller
    }

}

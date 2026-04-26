//
//  TabManager.swift
//  Navigation
//
//  Created by Mohamed Salah on 29/03/2026.
//

import SwiftUI
import UIKit

extension UITabBar {
    
    @MainActor
    static func setVisibility(_ visible: Bool, animated: Bool = true) {
        guard let tabBarController = findTabBarController() else { return }
        let tabBar = tabBarController.tabBar
        
        if animated {
            if visible {
                // Show tab bar - slide up from bottom
                tabBar.isHidden = false
                tabBar.transform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
                
                UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
                    tabBar.transform = .identity
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    tabBar.isHidden = true
                    tabBar.transform = .identity // Reset transform for next show
                }
            }
        } else {
            tabBar.isHidden = !visible
            tabBar.transform = .identity
        }
    }
    
    @MainActor
    private static func findTabBarController() -> UITabBarController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        return findTabBarController(in: window.rootViewController)
    }
    
    @MainActor
    private static func findTabBarController(in viewController: UIViewController?) -> UITabBarController? {
        guard let viewController = viewController else { return nil }
        
        if let tabBarController = viewController as? UITabBarController {
            return tabBarController
        }
        
        // search children
        for child in viewController.children {
            if let tabBarController = findTabBarController(in: child) {
                return tabBarController
            }
        }
        
        // search presented
        if let presented = viewController.presentedViewController {
            if let tabBarController = findTabBarController(in: presented) {
                return tabBarController
            }
        }
        
        return nil
    }
}
//@MainActor
//static func setVisibility(_ visible: Bool, animated: Bool = true) {
//    guard let tabBarController = findTabBarController() else { return }
//    let tabBar = tabBarController.tabBar
//    
//    if animated {
//        if visible {
//            // Show tab bar - slide up from bottom
//            tabBar.isHidden = false
//            tabBar.transform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
//            
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut]) {
//                tabBar.transform = .identity
//            }
//        } else {
//            // Hide tab bar - slide down
//            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseIn]) {
//                tabBar.transform = CGAffineTransform(translationX: 0, y: tabBar.frame.height)
//            } completion: { _ in
//                tabBar.isHidden = true
//                tabBar.transform = .identity // Reset transform for next show
//            }
//        }
//    } else {
//        tabBar.isHidden = !visible
//        tabBar.transform = .identity
//    }
//}

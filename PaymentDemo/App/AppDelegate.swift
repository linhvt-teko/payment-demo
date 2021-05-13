//
//  AppDelegate.swift
//  MinervaDemo
//
//  Created by linhvt on 4/16/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        if #available(iOS 13.0, *) {
            window!.overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        App.shared.attachWindow(window!)
        App.shared.appDidFinishLaunchingWithOptions(application, didFinishLaunchingWithOptions: launchOptions)
        return true
        
    }

}


//
//  AppDelegate.swift
//  PaymentDemo
//
//  Created by linhvt on 4/19/21.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        App.shared.attachWindow(window!)
        App.shared.appDidFinishLaunchingWithOptions(application, didFinishLaunchingWithOptions: launchOptions)
        
        return true
    }



}


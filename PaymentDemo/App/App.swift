//
//  App.swift
//  Example
//
//  Created by linhvt on 12/14/20.
//  Copyright © 2020 Tung Nguyen. All rights reserved.
//

import Foundation
import Terra
import MinervaUI
import TerraInstancesManager
import Toast_Swift
import ApolloTheme
import LoyaltyCore
import Janus
import IQKeyboardManagerSwift
import JanusGoogle

public var terraApp: ITerraApp = TerraInstanceCenter.shared.terraApp

public class TerraInstanceCenter {
    
    public static let shared = TerraInstanceCenter()

    var tempTerraApp: ITerraApp?
    
    var terraApp: ITerraApp! {
        return tempTerraApp!
    }
    
    var isTerraLoaded: Bool { return tempTerraApp != nil }
    
    func loadTerra(completion: @escaping (Bool) -> Void) {
        TerraApp.configure(appName: "MinervaDemo") { (isSuccess, terraApp) in
            guard isSuccess else {
                completion(false)
                return
            }
            TerraInstanceCenter.shared.tempTerraApp = terraApp
            TerraPaymentUI.configureWith(app: terraApp)
            TerraTheme.configureWith(app: terraApp)
            TerraLoyalty.configureWith(app: terraApp)
            TerraAuth.configureWith(app: terraApp)
            TerraAuth.auth(app: terraApp).registerGoogle()
            print(terraApp.bus.id)
            UserDefaults.standard.setValue(terraApp.bus.id, forKey: "vn.teko.terra.bus.app-host")
            completion(isSuccess)
        }
    }

}

class App {
    
    static let shared = App()
    var window: UIWindow!
    var application: UIApplication!
    var launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
    func setupTools() {
        // custom initialization
        setupToasts()
        setupIQKeyboardManager()
    }
    
    func attachWindow(_ window: UIWindow) {
        self.window = window
        self.window.backgroundColor = .black
    }
    
    func buildRootViewController() {
        let testVC = PaymentWithLoyaltyViewController(nibName: "PaymentWithLoyaltyViewController", bundle: nil)
        let navVC = UINavigationController(rootViewController: testVC)
        window?.rootViewController = navVC
        window?.makeKeyAndVisible()
    }

    
    
    func appDidFinishLaunchingWithOptions(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        self.application = application
        self.launchOptions = launchOptions
        buildRootViewController()
        setupTools()
    }

}

extension App {
    
    private func setupToasts() {
        // for toasts
        ToastManager.shared.duration =  5.0
        ToastManager.shared.isTapToDismissEnabled = true
        ToastManager.shared.isQueueEnabled = true
    }
    
    private func setupIQKeyboardManager() {
        // for IQKeyboardManager
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
    }
}

//
//  SplashModule.swift
//  PaymentDemo
//
//  Created linhvt on 4/19/21.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by LinhVT - @linh.deli
//

import UIKit

class SplashModule: SplashBuilderProtocol {

    static func build(dismissHandler: @escaping () -> Void) -> UIViewController {
        let view = SplashViewController(nibName: "SplashViewController", bundle: nil)
        let presenter = SplashPresenter(view: view, dismissHandler: dismissHandler)
        
        view.presenter = presenter
        
        return view
    }
    
    
    static func show(onViewController viewController: UIViewController, dismissHandler: @escaping () -> Void) {
        let vc = SplashModule.build(dismissHandler: dismissHandler)
        vc.modalPresentationStyle = .fullScreen
        viewController.present(vc, animated: true, completion: nil)
    }
    
}

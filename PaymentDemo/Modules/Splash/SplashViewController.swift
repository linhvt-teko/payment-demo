//
//  SplashViewController.swift
//  PaymentDemo
//
//  Created linhvt on 4/19/21.
//  Copyright © 2021 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by LinhVT - @linh.deli
//

import UIKit

class SplashViewController: BaseViewController {

    // MARK: - variables
	var presenter: SplashPresenterProtocol?

    // MARK: - outlets
    
    // MARK: - actions
    
    // MARK: - life cycle
	override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.viewDidLoad()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.isNavigationBarHidden = false

    }

    // MARK: - setup
}

// MARK: - ViewProtocol
extension SplashViewController: SplashViewProtocol {
    
    func showMessage(_ message: String) {
        showAlert(message)
    }
    
    func dismiss() {
        self.dismiss(animated: true, completion: nil)
    }
    
}

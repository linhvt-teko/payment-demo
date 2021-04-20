//
//  BaseViewController.swift
//  PaymentDemo
//
//  Created by linhvt on 4/19/21.
//

import UIKit
import SVProgressHUD

class BaseViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func showLoadingIndicator() {
        DispatchQueue.main.async {
            SVProgressHUD.show()
        }
    }
    
    func hideLoadingIndicator() {
        DispatchQueue.main.async {
            SVProgressHUD.dismiss()
        }
    }
}

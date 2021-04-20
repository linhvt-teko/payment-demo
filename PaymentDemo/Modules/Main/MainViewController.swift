//
//  MainViewController.swift
//  Example
//
//  Created by linhvt on 12/8/20.
//  Copyright © 2020 Tung Nguyen. All rights reserved.
//

import UIKit
import Minerva
import MinervaUI
import SVProgressHUD
import Toast_Swift

class MainViewController: BaseViewController {
    
    
    // MARK: - outlets
    
    // MARK: - variables
    
    let isDebug: Bool = {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }()
    
    // MARK: - life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showDebugUI(isDebug)
        SplashModule.show(onViewController: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func showDebugUI(_ isDebug: Bool) {
    }
    
    
    // MARK: - action
    @IBAction func openPaymentFtLoyaltyButtonWasTapped(_ sender: Any) {
        let vc = PaymentWithLoyaltyViewController(nibName: "PaymentWithLoyaltyViewController", bundle: nil)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func openWalletWasTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Mở Ví", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.text = "0999999998"
            textField.placeholder = "PHONE NUMBER"
        }
        
        alert.addTextField { (textField) in
            textField.text = "Nguyen"
            textField.placeholder = "CUSTOMER NAME"
        }
        
        alert.addAction(
            UIAlertAction(
                title: "Cancel",
                style: .cancel,
                handler: nil
            )
        )
        
        alert.addAction(
            UIAlertAction(
                title: "Mở Ví",
                style: .default,
                handler: { [weak alert] (_) in
                    let phoneNumber = alert!.textFields![0].text!
                    let name = alert!.textFields![1].text!
                    let customer = VNPayEWalletCustomer(phone: phoneNumber, name: name, email: nil)
                    do {
                        try TerraPaymentUI
                            .getInstance(by: terraApp)?
                            .openVNPayEWallet(customer: customer)
                    } catch {
                        self.showAlert(error.localizedDescription)
                    }
                    
                }
            )
        )
        
        self.present(alert, animated: true, completion: nil)
    }

}


// MARK: - AIOPaymentUIDelegate
extension MainViewController: AIOPaymentUIDelegate {
    func onPaymentResult(_ result: AIOPaymentResult) {
        switch result {
        case .success(let transactionResult):
            dump(transactionResult)
            showAlert(transactionResult.message)
        case .failure(let error, let transactionResult):
            if let requestId = transactionResult?.requestId {
                showAlert("Transaction \(requestId) error: \(error.localizedDescription)")
            } else {
                showAlert("Transaction error: \(error.localizedDescription)")
            }
        @unknown default: ()
        }

    }

    func onPaymentCancel() {
        showAlert("onPaymentCancel")
    }
}

//
//  UIViewController+showAlert.swift
//  PaymentDemo
//
//  Created by linhvt on 4/19/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(_ message: String) {
        let alert = UIAlertController(title: NSLocalizedString("Result", comment: ""), message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .cancel, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
}

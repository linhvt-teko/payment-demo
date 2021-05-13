//
//  UIViewController+showWarning.swift
//  MinervaDemo
//
//  Created by linhvt on 4/22/21.
//

import Foundation
import UIKit

extension UIViewController {
    
    func showAlert(_ message: String?) {
        let alert = UIAlertController(title: "Message", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
}


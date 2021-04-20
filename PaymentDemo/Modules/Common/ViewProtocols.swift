//
//  LoadingProtocol.swift
//  PaymentDemo
//
//  Created by linhvt on 4/19/21.
//

import Foundation

protocol LoadingProtocol {
    func showLoading()
    func hideLoading()
}

protocol ShowMessageProtocol {
    func showMessage(_ message: String)
}

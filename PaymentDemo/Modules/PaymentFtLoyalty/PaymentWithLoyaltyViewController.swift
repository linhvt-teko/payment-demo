//
//  PaymentWithLoyaltyViewController.swift
//  MinervaUI-Example
//
//  Created by linhvt on 4/13/21.
//

import UIKit
import DropDown
import MinervaUI
import Minerva

enum PaymentMethod: CaseIterable {
    case none
    case loyalty
    case qrMMS
    case qrGateway
    case spos
    case ewallet
    case momoGateway
    case qrReversal
    case atm
    case internationalCard
    
    var name: String {
        switch self {
        case .none:
            return "Chọn phương thức thanh toán"
        case .loyalty:
            return "Loyalty only"
        case .qrMMS:
            return "QRCode MMS"
        case .qrGateway:
            return "QRCode Cổng"
        case .qrReversal:
            return "QR Khách hàng"
        case .spos:
            return "Máy Spos"
        case .ewallet:
            return "Ví VNPay"
        case .momoGateway:
            return "MoMo app"
        case .atm:
            return "Thẻ ATM"
        case .internationalCard:
            return "Thẻ Debit/Credit"
        }
    }
}

class PaymentWithLoyaltyViewController: PaymentBaseViewController {
    
    @IBOutlet weak var orderCodeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var loyaltyAmountTextField: UITextField!
    @IBOutlet weak var methodTextField: UITextField!
    
    lazy var methods: [PaymentMethod] = PaymentMethod.allCases
    var selectedMethod: PaymentMethod = .none {
        didSet {
            self.methodTextField.text = selectedMethod.name
            self.updateViews()
        }
    }
    
    @IBAction func choosePaymentMethodsButtonWasTapped(_ sender: Any) {
        let dropDown = DropDown(frame: CGRect(x: 0, y: 0, width: methodTextField.frame.size.height, height: 400))
        
        dropDown.dataSource = methods.map { $0.name }
        dropDown.anchorView = methodTextField
        dropDown.bottomOffset = CGPoint(x: 0, y: methodTextField.frame.size.height)
        dropDown.animationEntranceOptions = .transitionCurlDown
        dropDown.animationExitOptions = .transitionCurlUp
        dropDown.show()
        dropDown.selectionAction = { [weak self] (index: Int, item: String) in
            guard let self = self else { return }
            self.methodTextField.text = item
            self.selectedMethod = self.methods[index]
        }
        
    }
    
    @IBAction func paymentButtonWasTapped(_ sender: Any) {
        
        switch selectedMethod {
        case .loyalty:
            paymentLoyaltyOnly()
        default:
            paymentFtLoyalty()
        }
        
    }
    
    func paymentLoyaltyOnly() {
        guard selectedMethod == .loyalty else { return }
        
        guard let orderCode = orderCodeTextField.text,
              let loyaltyAmount = Int(loyaltyAmountTextField.text ?? ""),
              loyaltyAmount > 0 else {
            return
        }
        
        let order = PaymentOrder(orderCode: orderCode, amount: Double(loyaltyAmount))
        let request = PaymentUIRequestBuilder
            .init(
                order: order,
                client: .init(
                    userId: "2c59afde1f11489b8d5bd2cd2674cf83",
                    escrowMerchantCode: nil
                )
            )
            .setLoyaltyMethod(points: loyaltyAmount, amount: Double(loyaltyAmount))
            .build()
        
        do {
            try TerraPaymentUI.getInstance(by: terraApp)?.payWith(request: request, delegate: self)
        } catch {
            print(error)
        }
        
    }
    
    func paymentFtLoyalty() {
        
        guard let orderCode = orderCodeTextField.text,
              let amount = Double(amountTextField.text ?? "") else {
            return
        }
        
        var onlineAmount = amount
        let loyaltyAmount = Int(loyaltyAmountTextField.text ?? "")
        
        if let loyaltyAmount = loyaltyAmount,
           loyaltyAmount > 0,
           selectedMethod != .loyalty {
            onlineAmount = onlineAmount - Double(loyaltyAmount)
        }
        
        let order = PaymentOrder(orderCode: orderCode, amount: amount)
        let builder = PaymentUIRequestBuilder.init(
            order: order,
            client: .init(
                userId: "2c59afde1f11489b8d5bd2cd2674cf83",
                escrowMerchantCode: nil
            )
        )
        
        
        switch selectedMethod {
        case .qrGateway:
            let _ = builder.setOnlineMethod(.vnPayQRGateway(amount: onlineAmount))
        case .qrMMS:
            let _ = builder.setOnlineMethod(.vnPayQRMMS(amount: onlineAmount))
        case .qrReversal:
            let _ = builder.setOnlineMethod(.vnPayQRReversal(amount: onlineAmount))
        case .spos:
            let _ = builder.setOnlineMethod(.sposApp(amount: onlineAmount))
        case .ewallet:
            let _ = builder.setOnlineMethod(
                .vnPayEWallet(
                    amount: onlineAmount,
                    customer: VNPayEWalletCustomer(
                        phone: "0999999998",
                        name: "Nguyen"
                    )
                )
            )
        case .momoGateway:
            let _ = builder.setOnlineMethod(.momoGateway(amount: onlineAmount))
        case .atm:
            let _ = builder.setOnlineMethod(.vnPayATMGateway(amount: onlineAmount))
        case .internationalCard:
            let _ = builder.setOnlineMethod(.vnPayInternationalCardGateway(amount: onlineAmount))
        case .loyalty:
            ()
        case .none:
            let _ = builder.setOnlineMethod(.all(amount: onlineAmount))
        }
        
        if let loyaltyAmount = loyaltyAmount, loyaltyAmount > 0 {
            let _ = builder.setLoyaltyMethod(
                points: loyaltyAmount,
                amount: Double(loyaltyAmount)
            )
        }
        
        let request = builder.build()
        do {
            try TerraPaymentUI.getInstance(by: terraApp)?.payWith(request: request, delegate: self)
        } catch {
            print(error)
        }
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DropDown.startListeningToKeyboard()
        orderCodeTextField.text = "order-abc-123"
        amountTextField.text = "10000"
        selectedMethod = .none
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = false
        updateViews()
    }
    
    func updateViews() {
        switch selectedMethod {
        case .loyalty:
            amountTextField.isHidden = true
        default:
            amountTextField.isHidden = false
        }
    }
    
}

extension PaymentWithLoyaltyViewController: AIOPaymentUIDelegate {
    func onPaymentCancel() {
        showAlert("Payment.cancelled")
    }
    
    func onPaymentResult(_ result: AIOPaymentResult) {
        switch result {
        case .success(let transactionResult):
            showAlert("Payment.success with request: \(transactionResult.requestId)")
        case .failure(let error, let transactionResult):
            showAlert("Payment.failure with error: \(error.localizedDescription)")
            print(transactionResult?.transactions)
        @unknown default:
            ()
        }
    }
}

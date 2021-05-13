//
//  PaymentWithLoyaltyViewController.swift
//  MinervaUI-Example
//
//  Created by linhvt on 4/13/21.
//

import UIKit
import DropDown
import MinervaUI
import Janus
import Minerva

enum PaymentMethod: CaseIterable {
    case none
    case loyalty
    case qrMMS
    case qrGateway
    case mobileBanking
    case spos
    case ewallet
    case momoGateway
    case qrReversal
    case atm
    case internationalCard
    case cod
    
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
        case .mobileBanking:
            return "Mobile Banking"
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
        case .cod:
            return "Thanh toán COD"
        }
    }
}

class PaymentWithLoyaltyViewController: PaymentBaseViewController {
    
    @IBOutlet weak var orderCodeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var loyaltyAmountTextField: UITextField!
    @IBOutlet weak var methodTextField: UITextField!
    
    @IBOutlet weak var walletCustomerInfoView: UIStackView!
    @IBOutlet weak var walletCustomerPhoneField: UITextField!
    @IBOutlet weak var walletCustomerNameField: UITextField!
    @IBOutlet weak var walletCustomerEmailField: UITextField!
    @IBOutlet weak var walletCustomerPartnerIdField: UITextField!
    
    @IBOutlet weak var showResultSwitch: UISwitch!
    @IBOutlet weak var btnLogin: UIButton!
    @IBOutlet weak var versionLabel: UILabel!

    lazy var methods: [PaymentMethod] = PaymentMethod.allCases
    var selectedMethod: PaymentMethod = .none {
        didSet {
            self.methodTextField.text = selectedMethod.name
            self.updateViews()
        }
    }
    
    var isAuthorized: Bool {
        let token = terraApp.servicesCredential?.accessToken
        return !(token?.isEmpty ?? true)
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
    
    @IBAction func loginGoogleWasTapped(_ sender: Any) {
        if isAuthorized {
            btnLogin.setTitle("Đăng nhập", for: .normal)
            btnLogin.backgroundColor = .systemRed
            TerraAuth.getInstance(by: terraApp)?.logoutGoogle()
        } else {
            TerraAuth.getInstance(by: terraApp)?.registerGoogle()
            TerraAuth.getInstance(by: terraApp)?.loginWithGoogle(presentViewController: self, delegate: self)
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
//                    userId: "2c59afde1f11489b8d5bd2cd2674cf83",
                    escrowMerchantCode: nil
                )
            )
            .setLoyaltyMethod(points: loyaltyAmount, amount: Double(loyaltyAmount))
            .setUIConfig(.init(shouldShowPaymentResult: showResultSwitch.isOn))
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
//                userId: "2c59afde1f11489b8d5bd2cd2674cf83",
                escrowMerchantCode: nil
            )
        )
        .setUIConfig(.init(shouldShowPaymentResult: showResultSwitch.isOn))
        
        
        switch selectedMethod {
        case .qrGateway:
            let _ = builder.setOnlineMethod(.vnPayQRGateway(amount: onlineAmount))
        case .mobileBanking:
            let _ = builder.setOnlineMethod(.mobileBanking(amount: onlineAmount))
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
                        partnerId: walletCustomerPartnerIdField.text ?? "",
                        phone: walletCustomerPhoneField.text ?? "",
                        name: walletCustomerNameField.text,
                        email: walletCustomerEmailField.text
                    )
                )
            )
        case .momoGateway:
            let _ = builder.setOnlineMethod(.momoGateway(amount: onlineAmount))
        case .atm:
            let _ = builder.setOnlineMethod(.vnPayATMGateway(amount: onlineAmount))
        case .internationalCard:
            let _ = builder.setOnlineMethod(.vnPayInternationalCardGateway(amount: onlineAmount))
        case .cod:
            let _ = builder.setOnlineMethod(.cod(amount: onlineAmount))
        case .loyalty:
            ()
        case .none:
            let customer = VNPayEWalletCustomer(
                partnerId: walletCustomerPartnerIdField.text ?? "",
                phone: walletCustomerPhoneField.text ?? "",
                name: walletCustomerNameField.text,
                email: walletCustomerEmailField.text
            )
            let _ = builder.setOnlineMethod(
                .all(
                    amount: onlineAmount,
                    metadata: [
                        .vnPayEWallet(customer: customer)
                    ]
                )
            )
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
        
        SplashModule.show(onViewController: self) { [weak self] in
            guard let self = self else { return }
            TerraAuth.getInstance(by: terraApp)?.refreshToken { (isSuccess, _, _) in
                self.updateAuthorizeState()
            }

        }
        
        DropDown.startListeningToKeyboard()
        
        orderCodeTextField.text = "order-abc-123"
        amountTextField.text = "10000"
        selectedMethod = .none
        
        walletCustomerNameField.text = "Nguyen Van a"
        walletCustomerPhoneField.text = "0918913795"
        walletCustomerEmailField.text = "078langha@gmail.com"
        walletCustomerPartnerIdField.text = "0918913795"
        
        walletCustomerNameField.isEnabled = true
        walletCustomerPhoneField.isEnabled = true
        walletCustomerEmailField.isEnabled = true
        walletCustomerPartnerIdField.isEnabled = true

        versionLabel.text = version()

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.isNavigationBarHidden = false
        updateViews()
    }
    
    func version() -> String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as? String ?? ""
        let build = dictionary["CFBundleVersion"] as? String ?? "1"
        return "v\(version)(\(build))"
    }
    
    func updateAuthorizeState() {
        guard TerraInstanceCenter.shared.isTerraLoaded else {
            return
        }
        if isAuthorized {
            self.btnLogin.setTitle("Đăng xuất", for: .normal)
            self.btnLogin.backgroundColor = .lightGray
        } else {
            self.btnLogin.setTitle("Đăng nhập", for: .normal)
            self.btnLogin.backgroundColor = .systemRed
        }
    }
    
    func updateViews() {
        // amountTextField
        switch selectedMethod {
        case .loyalty:
            amountTextField.isHidden = true
        default:
            amountTextField.isHidden = false
        }
        
        // ewalletCustomer
        switch selectedMethod {
        case .ewallet, .none:
            walletCustomerInfoView.isHidden = false
        default:
            walletCustomerInfoView.isHidden = true
        }
        
        updateAuthorizeState()
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
            if let transactionResult = transactionResult {
                showAlert(String(describing: error) + ":\n" + String(describing: transactionResult))
                print(String(describing: transactionResult.transactions))
            } else {
                showAlert(String(describing: error))
            }
        @unknown default:
            ()
        }
    }
}


extension PaymentWithLoyaltyViewController: JanusLoginDelegate {
    
    func janusWillGetAuthCredential() {
        
    }
    
    func janusHasLoginSuccess(authCredential: JanusAuthCredential) {
        btnLogin.setTitle("Đăng xuất", for: .normal)
        btnLogin.backgroundColor = .lightGray
    }
    
    func janusHasLoginFail(error: JanusError?) {
      
    }
    
}

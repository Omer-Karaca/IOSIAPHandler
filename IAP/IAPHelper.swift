//
//  IAPHelper.swift
//  facie
//
//  Created by Ömer Karaca on 31.03.2021.
//

import StoreKit
import SVProgressHUD
import Adjust

public typealias ProductIdentifier = String
public typealias ProductsRequestCompletionHandler = (_ success: Bool, _ products: [SKProduct]?) -> Void


extension Notification.Name {
    static let IAPHelperPurchaseNotification = Notification.Name("IAPHelperPurchaseNotification")
}

protocol PurchaseSuccessUIUpdateDelegate {
    func purchaseSuccessUpdateUI(productIdentifier: String)

}

open class IAPHelper: NSObject  {

    //UI Update Delegate
    var purchaseSuccessUIUpdateDelegate: PurchaseSuccessUIUpdateDelegate?

    //App Secret
    static let sharedSecret = "26c96788bec1405799a6fdf3b8a6bab5"//MARK: DON'T FORGET TO CHANGE
    //Encyrption.resolveEncrypt("%H3dgQq9c698pf:29Dm8Bedgf:h]<gM7vxhLE34370S;?0:H8gM4<8V<jVf9rf4Kd2wi]L3[XgdCf=u5kv7f9<7PfD3;eH89Wgg&")

    //Price Formatter
    static let priceFormatter: NumberFormatter = {
        let formatter = NumberFormatter()

        formatter.formatterBehavior = .behavior10_4
        formatter.numberStyle = .currency

        return formatter
    }()

    private let productIdentifiers: Set<ProductIdentifier>
    private var productsRequest: SKProductsRequest?
    private var productsRequestCompletionHandler: ProductsRequestCompletionHandler?

    //For subscription part
    public var refreshSubscriptionSuccessBlock : SuccessBlock?
    public var refreshSubscriptionFailureBlock : FailureBlock?
    public var lastSubscriptionStatusCheck: TimeInterval  = 0

    //Eligible For Introductory Price
    public static var eligibleForIntroductoryPrice: Bool = true

    //Restore Message Run Once
    var restoreMessageRunOnce = true
    public static var selectedProduct: SKProduct?
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        super.init()
        SKPaymentQueue.default().add(self)

    }
}

// MARK: - StoreKit API

extension IAPHelper {

    public func requestProducts(_ completionHandler: @escaping ProductsRequestCompletionHandler) {
        productsRequest?.cancel()
        productsRequestCompletionHandler = completionHandler

        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        print("Product identifiers: \(productIdentifiers)")
        productsRequest!.delegate = self
        productsRequest!.start()
    }

    public func buyProduct(_ product: SKProduct) {

        print("Buying \(product.productIdentifier)...")

        SVProgressHUD.show()

        let payment = SKPayment(product: product)
        SKPaymentQueue.default().add(payment)
    }

//    public func isProductPurchased(_ productIdentifier: ProductIdentifier) -> Bool {
//        return purchasedProductIdentifiers.contains(productIdentifier)
//    }

    public class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }

    public func restorePurchases() {

        SVProgressHUD.show()
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

// MARK: - SKProductsRequestDelegate

extension IAPHelper: SKProductsRequestDelegate {

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        let products = response.products
        productsRequestCompletionHandler?(true, products)
        clearRequestAndHandler()

//        for p in products {
//            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
//        }
    }

    public func request(_ request: SKRequest, didFailWithError error: Error) {
        print("IAP Request Failed.")
        print("Error: \(error.localizedDescription)")
        productsRequestCompletionHandler?(false, nil)
        clearRequestAndHandler()
    }

    public func requestDidFinish(_ request: SKRequest) {
        print("Inside requestDidFinish")
        // call refresh subscriptions method again with same blocks
        if request is SKReceiptRefreshRequest {
            print("Receipt refresh success! Calling refreshSubscriptionsStatus again...")
            self.refreshSubscriptionsStatus()
        }
    }

    private func clearRequestAndHandler() {
        productsRequest = nil
        productsRequestCompletionHandler = nil
    }
}

// MARK: - SKPaymentTransactionObserver

extension IAPHelper: SKPaymentTransactionObserver {

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased:
                SVProgressHUD.dismiss()
                complete(transaction: transaction)
                break
            case .failed:
                SVProgressHUD.dismiss()
                fail(transaction: transaction)
                break
            case .restored:
                SVProgressHUD.dismiss()
                restore(transaction: transaction)
                break
            case .deferred:
                SVProgressHUD.dismiss()
                break
            case .purchasing:
                break
            @unknown default:
                SVProgressHUD.dismiss()
                print("UNKNOWN ERROR IN PAYMENT QUEUE")
            }
        }
    }

    private func complete(transaction: SKPaymentTransaction) {

        deliverPurchaseNotificationFor(identifier: transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)

        buySuccessCompletion(identifier: transaction.payment.productIdentifier)
        if let selectedProduct = IAPHelper.selectedProduct {
            sendSubscriptionToAdjust(price: selectedProduct.price, currency: selectedProduct.priceLocale.currencyCode!, transaction: transaction)
        } else {
            sendSubscriptionToAdjust(price: 10, currency: "", transaction: transaction)
        }

        print("Purchase complete!")
    }

    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }

        print("restore... \(productIdentifier)")

        deliverPurchaseNotificationFor(identifier: productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)

        restoreSuccessCompletion(identifier: productIdentifier)

        print("Restoring Complete")

        //Message
//        if let topVC = UIApplication.getTopViewController(){
//            if restoreMessageRunOnce{
//                restoreMessageRunOnce = false
//                //Alert
//                let alert = UIAlertController(title: "Restore", message: "Purchase restoring complete.", preferredStyle: .alert)
//                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
//                topVC.present(alert, animated: true)
//            }
//        }

    }

    private func fail(transaction: SKPaymentTransaction) {
        print("fail...")
        if let transactionError = transaction.error as NSError?,
            let localizedDescription = transaction.error?.localizedDescription,
            transactionError.code != SKError.paymentCancelled.rawValue {
            print("Transaction Error: \(localizedDescription)")
        }

        SKPaymentQueue.default().finishTransaction(transaction)
    }

    private func deliverPurchaseNotificationFor(identifier: String?) {
        guard let identifier = identifier else { return }

        NotificationCenter.default.post(name: .IAPHelperPurchaseNotification, object: identifier)
    }

    func buySuccessCompletion(identifier: String){

        print("Buy Success Completion!!!")

        //UDH.setEncyriptedValue(key: UDH.IS_PRO_MEMBER, value: true)
        //REFRESH SUBSCRIPTION
        //refreshSubscriptionsStatus()

        //Temporarily Activate Premium
        IAPHelper.temporaryActivation()
        //UI
        purchaseSuccessUIUpdateDelegate?.purchaseSuccessUpdateUI(productIdentifier: identifier)
    }

    static func temporaryActivation(){
        //Temporary Activation
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let tomorrow = Date().addingTimeInterval(TimeInterval(86400))
        let tomorrowString = "\(formatter.string(from: tomorrow)) Etc/GMT"
        //UDH.setEncyriptedValue(key: UDH.SUBSCRIPTION_EXPIRATION_DATE, value: tomorrowString)
    }

    func restoreSuccessCompletion(identifier: String){

        print("Restore Success Completion!!!")

        refreshSubscriptionsStatus()

    }


    static func shouldRefreshUI(){

    }

}

//MARK: - shouldAddStorePayment

extension IAPHelper{

    public func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {

        //Buy the product
        //MyFunctions.openProVc()

        return true

        //To hold
        //return false

        //And then to continue
        //SKPaymentQueue.default().add(savedPayment)
    }

    //Lifetime
    func sendLifetimeReportToAdjust(price: Float, currency: String, transaction: SKPaymentTransaction) {
            print("Reporting lifetime purchase to Adjust. Transaction Identifier: \(String(describing: transaction.transactionIdentifier)), price: \(price), currency: \(currency)")
            let event = ADJEvent(eventToken: "adjustLifetimePurchaseToken")//TODO
            event?.setRevenue(Double(price), currency: currency)
            if let transactionId = transaction.transactionIdentifier{
                event?.setTransactionId(transactionId)
            }
            Adjust.trackEvent(event)
    }

    //Subscription
    func sendSubscriptionToAdjust(price: NSDecimalNumber, currency: String, transaction: SKPaymentTransaction){
        print("sending SubscriptionToAdjust")
        guard let transactionId = transaction.transactionIdentifier, let receiptUrl = Bundle.main.appStoreReceiptURL, let receipt = try? Data(contentsOf: receiptUrl) else{
            print("Adjust subscription report error. Parameters are nil");return}

        guard let subscription = ADJSubscription(
            price: price,
            currency: currency,
            transactionId: transactionId,
            andReceipt: receipt) else {
                print("Adjust subscription report error. Subscription object is nil.")
                return
            }

        if let date = transaction.transactionDate, let region = Locale.current.regionCode{
            subscription.setTransactionDate(date)
            subscription.setSalesRegion(region)
        }

        Adjust.trackSubscription(subscription)
        print("Adjust subscription successfully tracked. ID: \(subscription.transactionId)")
    }
}

//
//  IAHelper+Subscriptions.swift
//  facie
//
//  Created by Ömer Karaca on 31.03.2021.
//

import Foundation
import StoreKit

public typealias SuccessBlock = (String?) -> Void
public typealias FailureBlock = (Error?) -> Void

extension IAPHelper{
    
    
    func refreshSubscriptionsStatus()
    {
        
        //Check time to overwhelming server
        if Date().timeIntervalSince1970 - self.lastSubscriptionStatusCheck < 1{
            print("Cancelling status request. Too many!")
            return
        }
        self.lastSubscriptionStatusCheck = Date().timeIntervalSince1970
        
        // save blocks for further use
        self.refreshSubscriptionSuccessBlock = subscriptionSuccessCallback
        self.refreshSubscriptionFailureBlock = subscriptionFailCallback
        guard let receiptUrl = Bundle.main.appStoreReceiptURL else {
                print("Refresh Subscription Status can't decide. Will refresh recepit...")
                refreshReceipt()
                // do not call block yet
                return
        }
        
        //Lambda URL
        let urlString = "https://krtiuy73y0.execute-api.us-west-2.amazonaws.com/live/verify-receipt"
        
        //Data
        let receiptData = try? Data(contentsOf: receiptUrl).base64EncodedString()
        //print("REQUEST RECEIPT DATA: \(receiptData ?? "NO DATA!")")
        let requestData = ["receipt-data" : receiptData ?? "", "password" : IAPHelper.sharedSecret, "exclude-old-transactions" : true] as [String : Any]
        
        
        //Request
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.setValue("Application/json", forHTTPHeaderField: "Content-Type")
        let httpBody = try? JSONSerialization.data(withJSONObject: requestData, options: [])
        request.httpBody = httpBody
        
        URLSession.shared.dataTask(with: request)  { (data, response, error) in
            DispatchQueue.main.async {
                if data != nil {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: .allowFragments){
                        
                        
                        self.parseReceipt(json as! Dictionary<String, Any>)
                        return
                    }
                } else {
                    print("error validating receipt: \(error?.localizedDescription ?? "")")
                }
                self.refreshSubscriptionFailureBlock?(error)
                self.cleanUpRefeshReceiptBlocks()
            }
        }.resume()
    }
    
    public func refreshReceipt(){
        print("Inside refreshReceipt")
        let request = SKReceiptRefreshRequest(receiptProperties: nil)
        request.delegate = self
        request.start()
    }
    
    
    private func parseReceipt(_ json : Dictionary<String, Any>) {
        print("Inside parseReceipt")
        //guard let json = json else{return}
        // It's the most simple way to get latest expiration date. Consider this code as for learning purposes. Do not use current code in production apps.
        
        //print("RECEIPT JSON: \(json)")
        
        guard let receipts_array = json["latest_receipt_info"] as? [Dictionary<String, Any>] else {
            self.refreshSubscriptionFailureBlock?(nil)
            self.cleanUpRefeshReceiptBlocks()
            print("NO RECEIPT ARRAY")
            return
        }
        
        
        //print("JSON: \(receipts_array)")
      
        //Iterate
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        var productId: String? = nil
        for receipt in receipts_array {
         
            if let expireDateStr = receipt["expires_date"] as? String{
                
                //Write expiration date to Prefs
                print("=====")
                print("Writing Expiration Date: \(expireDateStr)" )
                //Write to Prefs
                //UDH.setEncyriptedValue(key: UDH.SUBSCRIPTION_EXPIRATION_DATE, value: expireDateStr)
                
                //Check If Refunded
                if let _ = receipt["cancellation_date"]{
                    print("Writing SUBSCRIPTION_REFUNDED = 1")
                    //UDH.set(key: UDH.SUBSCRIPTION_REFUNDED, value: 1)
                }else{
                    //UDH.set(key: UDH.SUBSCRIPTION_REFUNDED, value: 0)
                }
                
                //Save productId
                productId = receipt["product_id"] as? String
            }
            
        }
        
        //Grace Period
        if let pending_renewal_array = json["pending_renewal_info"] as? [Dictionary<String, Any>]{
            for pending_renewal in pending_renewal_array{
                if let graceExpireDateStr = pending_renewal["grace_period_expires_date"] as? String{
                    print("Writing Grace Date: \(graceExpireDateStr)" )
                    //UDH.setEncyriptedValue(key: UDH.GRACE_EXPIRATION_DATE, value: graceExpireDateStr)
                }
            }
        }
        
        self.refreshSubscriptionSuccessBlock?(productId)
        self.cleanUpRefeshReceiptBlocks()
    }
    
    private func cleanUpRefeshReceiptBlocks(){
        self.refreshSubscriptionSuccessBlock = nil
        self.refreshSubscriptionFailureBlock = nil
    }
    
    //Callbacks ========
    
    func subscriptionSuccessCallback(productId: String?)//->Product Id is for setting user property
    {
        print("Sucecss calling refreshSubscriptionsStatus")
        IAPHelper.handleSubscriptionActivation(productId: productId)
        
        IAPHelper.shouldRefreshUI()
    }
    
    func subscriptionFailCallback(e: Error?){
        print("Fail calling refreshSubscriptionsStatus: \(String(describing: e))")
        IAPHelper.handleSubscriptionActivation(productId: nil)

        
        IAPHelper.shouldRefreshUI()
    }
    
}

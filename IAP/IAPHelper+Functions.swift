//
//  IAPHelper+Functions.swift
//  facie
//
//  Created by Ömer Karaca on 31.03.2021.
//

import Foundation
//import Firebase
import FirebaseAnalytics
//Subscriber Type User Property:
//1. Subscription için: "productId"
//2. Ex için: "ex productId"
//3. Grace için "grace productId"
//3. Refund için "refunded productId"
//5. Premium için: "ultimatefacts_premium"

extension IAPHelper{
    
    public static func checkIfExpirationIsInFuture(expirationDateStr: String) -> Bool{
            
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss VV"
        
        if let expDate = formatter.date(from: expirationDateStr){
            if expDate >= Date(){
                return true
            }else{
                return false
            }
        }else{
            assert(false, "ERROR: checkIfSubscriptionActive")
            return false
        }
    }
    
    static func handleSubscriptionActivation(productId: String?){
    
        //Date Check
//        guard let expDateStr = UDH.getEncyriptedString(key: UDH.SUBSCRIPTION_EXPIRATION_DATE) else{
//            assert(false)
//            return
//        }
        let expDateStr = ""
        
        if IAPHelper.checkIfExpirationIsInFuture(expirationDateStr: expDateStr)
        {
            print("Handling subscription. Switching to premium...")
            
            //Switch
            switchToPremium()
            
            //User Property
            if let productId = productId{
                let property = productId
                print("Setting user property: \(property)")
                Analytics.setUserProperty(property, forName: "subscriber_type")
                //UDH.setEncyriptedValue(key: UDH.SUBSCRIPTION_TYPE, value: property)
            }
            
        }
        else
        {
            //Grace Period
//            guard let graceExpDateStr = UDH.getEncyriptedString(key: UDH.GRACE_EXPIRATION_DATE) else{
//                assert(false)
//                return
//            }
            let graceExpDateStr = ""
            
            if IAPHelper.checkIfExpirationIsInFuture(expirationDateStr: graceExpDateStr)
            {
                print("Handling subscription. User in grace. Switching to premium...")
                
                //Switch
                switchToPremium()
                
                //User Property
                if let productId = productId{
                    let property = "grace \(productId)"
                    print("Setting user property: \(property)")
                    Analytics.setUserProperty(property, forName: "subscriber_type")
                    //UDH.setEncyriptedValue(key: UDH.SUBSCRIPTION_TYPE, value: property)
                }
                
                //Warning
//                if let topVC = UIApplication.getTopViewController() {
//                   //Alert
//                   let alert = UIAlertController(title: "Billing Error", message: "Your subscription can't be renewed and will be cancelled in a short time. Please update your App Store account payment information", preferredStyle: .alert)
//                   alert.addAction(UIAlertAction(title: "Update", style: .default, handler: {(UIAlertAction) in
//                    let urlString = "https://apps.apple.com/account/billing"
//                    if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url){
//                        //Open payment management page
//                        UIApplication.shared.open(url)
//                    }
//                   }))
//                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
//                   topVC.present(alert, animated: true)
//                }
            }
            else
            {
                print("Handling subscription. Switching to basic...")
                
                //Switch
                switchToBasic()
                
                //User Property
                if let productId = productId{
                    let property = "ex \(productId)"
                    print("Setting user property: \(property)")
                    Analytics.setUserProperty(property, forName: "subscriber_type")
                    //UDH.setEncyriptedValue(key: UDH.SUBSCRIPTION_TYPE, value: property)
                }
            }
        }
        
        //If Refunded Switch To Basic
        let refunded = 0//UDH.getEncyriptedInt(key: UDH.SUBSCRIPTION_REFUNDED)
        if refunded == 1 {
            
            print("Handling subscription. Switching to basic because refunded!")
            
            //Switch
            switchToBasic()
            
            //User Property
            if let productId = productId{
                let property = "refunded \(productId)"
                print("Setting user property: \(property)")
                Analytics.setUserProperty(property, forName: "subscriber_type")
                //UDH.setEncyriptedValue(key: UDH.SUBSCRIPTION_TYPE, value: property)
            }
        }
        
        
    }
    
    static func switchToPremium() {
        print("SWITCHING TO PREMIUM")

        //UDH.setEncyriptedValue(key: UDH.IS_PRO_MEMBER, value: true)
        
        //widgetManager.setProStatus(true)
    }
    
    static func switchToBasic() {
        print("SWITCHING TO BASIC")

        //UDH.setEncyriptedValue(key: UDH.IS_PRO_MEMBER, value: false)
        //widgetManager.setProStatus(false)
    }
    
}

////
////  IAPProductFetcher.swift
////  facie
////
////  Created by Ömer Karaca on 31.03.2021.
////
//
//import Foundation
//import StoreKit
//import SVProgressHUD
//import FirebaseAnalytics
//
//protocol ProductUIUpdateDelegate {
//    func updateUI(products: [SKProduct]?)
//}
//
//class IAPProductFetcher {
//    
//    //Products
//    var products:  [SKProduct]?
//    
//    //UI Update Delegate
//    var productUIUpdateDelegate: ProductUIUpdateDelegate?
//    
//    
//    func requestProductsFromStore() {
//        SVProgressHUD.show()
//        print("Requesting Products From Store")
//        IAPProducts.store.requestProducts{ success, products in
//            if success {
//                
//                self.products = products
//                self.productUIUpdateDelegate?.updateUI(products: products)
//                
//            }else{
//                print("reload is not success")
//            }
//        }
//    }
//    
//    func getProduct(byIdentifier identifier: String) -> SKProduct?{
//        
//        guard let products = self.products else{
//            return nil
//        }
//        for p in products{
//            
//            if p.productIdentifier == identifier{
//                return p
//            }
//        }
//        
//        return nil
//    }
//    
//}
//

//
//  IAPProducts.swift
//  facie
//
//  Created by Ömer Karaca on 31.03.2021.
//

import Foundation

public struct IAPProducts {


    //Product Ids
//    static var FITWALK_YEARLY_SUBS = RemoteVariables.remoteConfig.configValue(forKey: RemoteVariables.FITWALK_YEARLY_SUBS).stringValue ?? RemoteVariables.FITWALK_YEARLY_SUBS
    static var YEARLY_SUBS = "YEARLY_SUBS"

    private static var productIdentifiers: Set<ProductIdentifier> = {

        return createIdentifiers()

    }()

    public static var store = IAPHelper(productIds: IAPProducts.productIdentifiers)


    static func refreshProductIds() {
        //Refresh product Ids
//        IAPProducts.FITWALK_YEARLY_SUBS = RemoteVariables.remoteConfig.configValue(forKey: RemoteVariables.FITWALK_YEARLY_SUBS).stringValue ?? RemoteVariables.FITWALK_YEARLY_SUBS
        IAPProducts.YEARLY_SUBS = "YEARLY_SUBS"
        //Set Identifiers
        productIdentifiers = createIdentifiers()
        //Set store
        store = IAPHelper(productIds: IAPProducts.productIdentifiers)
    }

    static func createIdentifiers() -> Set<ProductIdentifier> {
        var identifiers = Set<ProductIdentifier>()

//        identifiers.insert(FITWALK_YEARLY_SUBS)
        identifiers.insert(YEARLY_SUBS)
        return identifiers

    }
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

//
//  Merchant.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 4/3/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class Merchant {
    
    var itemName: String
    var merchant: String
    var country: String
    var price: Double
    var url: String
    
    init (itemName: String, merchant: String, country: String, price: Double, url: String) {
        self.itemName = itemName
        self.merchant = merchant
        self.country = country
        self.price = price
        self.url = url
    }
}

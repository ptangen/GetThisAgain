//
//  Item.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class Item {
    
    let barcode: Int
    let barcodeType: Constants.barcodeType
    let name: String
    let categoryText: String
    let imageURL: String
    var shoppingList: Bool
    
    init (barcode: Int, barcodeType: Constants.barcodeType, name: String, categoryText: String, imageURL: String, shoppingList: Bool) {
        self.barcode = barcode
        self.barcodeType = barcodeType
        self.name = name
        self.categoryText = categoryText
        self.imageURL = imageURL
        self.shoppingList = shoppingList
    }
}

//
//  Datastore.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class DataStore {
    static let sharedInstance = DataStore()
    fileprivate init() {}
    
    var myItems = [MyItem]()
    
    func getItemFromBarcode(barcode: String) -> MyItem? {
        for item in myItems {
            if item.barcode == barcode {
                return item
            }
        }
        return nil
    }
    
    

}

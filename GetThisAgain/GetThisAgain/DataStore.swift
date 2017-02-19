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
    
    var myItems = [Item]()
    
    func getSampleData() {
        let myItem1 = Item(barcode: "0073852009385", name: "Purell H/Sanit Gel Aloe 2oz", categoryText: "Bath / Beauty / Hygiene", imageURL: "http://eandata.com/image/products/007/385/200/0073852009385.jpg", shoppingList: false, getThisAgain: .yes)
        self.myItems.append(myItem1)
    }
}

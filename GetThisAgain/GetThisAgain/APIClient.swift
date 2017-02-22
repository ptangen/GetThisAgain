//
//  APIClient.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class APIClient {
    
    class func getItemFromAPI(barcode: String, completion: @escaping (Item) -> Void) {
        
        let urlString = "\(Secrets.eandataAPIURL)&keycode=\(Secrets.keyCode)&find=\(barcode)"
        let url = URL(string: urlString)
        var itemInst: Item?

        if let unwrappedUrl = url{
            let session = URLSession.shared
            let task = session.dataTask(with: unwrappedUrl) { (data, response, error) in
                if let unwrappedData = data {
                    do {
                        let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any]
                        if let responseJSON = responseJSON {
                            // check the status code and create object
                            let statusDict = responseJSON["status"] as! [String:String]
                            if let code = statusDict["code"] {
                                if code == "200" {
                                    let productDict = responseJSON["product"] as! [String:Any]
                                    let productAttributesDict = productDict["attributes"] as! [String : String]
                                    
                                    // create the item object
                                    if let name = productAttributesDict["product"] {
                                        itemInst = Item(barcode: barcode, name: name, category: "", imageURL: "", shoppingList: false, getThisAgain: .unsure)
                                        
                                        // set the imageURL and category values if we have them
                                        if let itemInst = itemInst {
                                            if let imageURL = productDict["image"] as? String { itemInst.imageURL = imageURL }
                                            if let category = productAttributesDict["category_text"] { itemInst.category = category }
                                        }
                                    }
                                } else {  // code != 200 - item not found
                                    itemInst = Item(barcode: "notFound", name: "", category: "", imageURL: "", shoppingList: false, getThisAgain: .unsure)
                                }
                            }
                        }
                        if let itemInst = itemInst {
                            completion(itemInst)
                        }
                    } catch {
                        print("An error occured when creating responseJSON")
                    }
                }
            }
            task.resume()
        }
    }
}

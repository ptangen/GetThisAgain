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
    
    class func requestAuth(userName: String, password: String, completion: @escaping (apiResponse) -> Void) {
        guard let userNameSubmitted = userName.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) else {
            completion(.userNameInvalid)
            return
        }
        
        guard let passwordSubmitted = password.addingPercentEncoding(withAllowedCharacters: .urlPasswordAllowed) else {
            completion(.passwordInvalid)
            return
        }
        
        let urlString = "\(Secrets.gtaURL)/auth.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let parameterString = "userNameSubmitted=\(userNameSubmitted)&passwordSubmitted=\(passwordSubmitted)"
            request.httpBody = parameterString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String]
                            let results = json?["results"]
                            print("results: \(results)")
                            
                            if results == "authenticated" {
                                completion(.authenticated)
                            } else if results == "userNameInvalid" {
                                completion(.userNameInvalid)
                            } else if results == "passwordInvalid" {
                                completion(.passwordInvalid)
                            } else {
                                completion(.noReply)
                            }
                        } catch {
                            completion(.noReply)
                        }
                    }
                }
            }).resume()
        } else {
            print("error: unable to unwrap url")
        }
    }
    
    class func getItemFromAPI(barcode: String, completion: @escaping (Item) -> Void) {
        
        let urlString = "\(Secrets.eandataAPIURL)&keycode=\(Secrets.keyCode)&find=\(barcode)"
        let url = URL(string: urlString)
        var itemInst: Item?
        let itemInstNotFound = Item(barcode: "notFound", name: "", category: "", imageURL: "", shoppingList: false, getThisAgain: .unsure)

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
                                    
                                    if productDict["attributes"] != nil {
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
                                    }
                                }
                            }
                        }
                        let itemInstUnwrapped = itemInst ?? itemInstNotFound
                        completion(itemInstUnwrapped)
                    } catch {
                        print("An error occured when creating responseJSON")
                    }
                }
            }
            task.resume()
        }
    }
}

enum apiResponse {
    case authenticated
    case userNameInvalid
    case passwordInvalid
    case noReply
    case ok
    case failed
}

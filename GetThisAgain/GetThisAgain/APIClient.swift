//
//  APIClient.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation
import UIKit

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
    
    class func insertMyItem(itemInst: MyItem, completion: @escaping (apiResponse) -> Void) {
        let urlString = "\(Secrets.gtaURL)/insertMyItem.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            var parameterString = String()
            if let nameUnwrapped = itemInst.name.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed), let categoryUnwrapped = itemInst.category.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed), let userName = UserDefaults.standard.value(forKey: "username") as? String {
                parameterString = "userName=\(userName)&barcode=\(itemInst.barcode)&name=\(nameUnwrapped)&category=\(categoryUnwrapped)&imageURL=\(itemInst.imageURL)&shoppingList=\(itemInst.shoppingList)&getAgain=\(itemInst.getAgain)&key=\(Secrets.gtaKey)"
            }
            request.httpBody = parameterString.data(using: .utf8)
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Int]
                            if let results = json?["results"] {
                                if results == 1 {
                                    completion(.ok)
                                } else if results == -1 {
                                    completion(.failed)
                                } else {
                                    completion(.noReply)
                                }
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
    
    class func getEandataFromAPI(barcode: String, completion: @escaping (MyItem) -> Void) {
        let urlString = "\(Secrets.eandataAPIURL)&keycode=\(Secrets.keyCode)&find=\(barcode)"
        let url = URL(string: urlString)
        var itemInst: MyItem?
        let itemInstNotFound = MyItem(barcode: "notFound", name: "", category: "", imageURL: "", shoppingList: false, getAgain: .unsure)

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
                                            itemInst = MyItem(barcode: barcode, name: name, category: "", imageURL: "", shoppingList: false, getAgain: .unsure)
                                        
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
    
    class func selectMyItems(userName: String, completion: @escaping (Bool) -> Void) {
        let store = DataStore.sharedInstance
        let urlString = "\(Secrets.gtaURL)/selectMyItems.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let parameterString = "key=\(Secrets.gtaKey)&userName=\(userName)"
            request.httpBody = parameterString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let unwrappedData = data {
                    do {
                        let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [[String: String]]
                        if let responseJSON = responseJSON {
                            for myItemDict in responseJSON {
                                
                                 //unwrap the incoming data and create item objects in datastore
                                if let barcode = myItemDict["barcode"],
                                    let name = myItemDict["name"],
                                    let category = myItemDict["category"],
                                    let imageURL = myItemDict["imageURL"],
                                    let shoppingListString = myItemDict["shoppingList"],
                                    let getAgainString = myItemDict["getAgain"] {
                                    
                                    // shoppingList
                                    var shoppingList: Bool!
                                    shoppingListString == "true" ? (shoppingList = true) : (shoppingList = false)
                                    
                                    // getAgain
                                    var getAgain: GetAgain!
                                    
                                    switch getAgainString {
                                    case ".yes":
                                        getAgain = GetAgain.yes
                                    case ".no":
                                        getAgain = GetAgain.no
                                    default:
                                        getAgain = GetAgain.unsure
                                    }
                                    
                                    // add myItem to datastore
                                    let myItemInst = MyItem(barcode: barcode, name: name, category: category, imageURL: imageURL, shoppingList: shoppingList, getAgain: getAgain)
                                    store.myItems.append(myItemInst)
                                }
                            }
                        }
                        completion(true)
                    } catch {
                        completion(false) // An error occurred when creating responseJSON
                    }
                }
            }).resume()
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

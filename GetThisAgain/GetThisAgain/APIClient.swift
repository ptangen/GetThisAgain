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
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {
                                let results = json["results"]
                            
                                if results == "authenticated" {
                                    completion(.authenticated)
                                } else if results == "userNameInvalid" {
                                    completion(.userNameInvalid)
                                } else if results == "passwordInvalid" {
                                    completion(.passwordInvalid)
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
    
    class func insertMyItem(itemInst: MyItem, image: UIImage?, completion: @escaping (apiResponse, String, String) -> Void) {
        
        // prepare image for upload
        let urlString = "\(Secrets.gtaURL)/insertMyItem.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)

            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            if let image = image {  // create request with image and parameters, barcode value generated on the server
                
                let boundary = "Boundary-\(NSUUID().uuidString)"
                let body = NSMutableData();
                
                request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
                
                if let itemNameUnwrapped = itemInst.itemName.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed), let createdBy = UserDefaults.standard.value(forKey: "userName") as? String {

                    let param = [
                        "createdBy"     : createdBy,
                        "itemName"      : itemNameUnwrapped,
                        "categoryID"    : String(itemInst.categoryID),
                        "shoppingList"  : String(itemInst.listID),
                        "getAgain"      : String(describing: itemInst.getAgain),
                        "merchants"     : String(itemInst.merchants),
                        "key"           : Secrets.gtaKey
                    ]
                
                    // add key value pairs to the body of the request
                    for (key, value) in param {
                        body.append("--\(boundary)\r\n".data(using: .utf8)!)
                        body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
                        body.append("\(value)\r\n".data(using: .utf8)!)
                    }
                
                    if let imageData = UIImageJPEGRepresentation(image, 1) {
                        // append the file
                        let filename = "itemsImage.jpg"
                        let mimetype = "image/jpg"
                        body.append("--\(boundary)\r\n".data(using: .utf8)!)
                        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
                        body.append("Content-Type: \(mimetype)\r\n\r\n".data(using: .utf8)!)
                        body.append(imageData as Data)
                        body.append("\r\n".data(using: .utf8)!)
                    }
                
                    body.append("--\(boundary)--\r\n".data(using: .utf8)!)
                    request.httpBody = body as Data
                }
            } else {   // create request without image
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                var parameterString = String()
                if let itemNameUnwrapped = itemInst.itemName.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed), let createdBy = UserDefaults.standard.value(forKey: "userName") as? String {
                    parameterString = "createdBy=\(createdBy)&barcode=\(itemInst.barcode)&itemName=\(itemNameUnwrapped)&categoryID=\(itemInst.categoryID)&imageURL=\(itemInst.imageURL)&listID=\(itemInst.listID)&getAgain=\(itemInst.getAgain)&merchants=\(itemInst.merchants)&key=\(Secrets.gtaKey)"
                    }
                    request.httpBody = parameterString.data(using: .utf8)
            }
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                if let results = json["results"] as! Int? {
                                    if results == 1 {
                                        // extract the imageURL and barcode from the results so we can creare the object in all cases
                                        if let barcode = json["barcode"] as! String? {
                                            var imageURLString = String() // sometimes there is no image
                                            if let imageURL = json["imageURL"] {
                                                imageURLString = (imageURL as? String)!
                                            } else {
                                                imageURLString = ""
                                            }
                                            completion(.ok, imageURLString, barcode)
                                        }
                                    } else if results == -1 {
                                        completion(.failed, "", "")
                                    } else {
                                        completion(.noReply, "", "")
                                    }
                                }
                            }
                        } catch {
                            completion(.noReply, "", "")
                        }
                    }
                }
            }).resume()
        } else {
            print("error: unable to unwrap url")
        }
    }
    
    class func deleteMyItem(createdBy: String, barcode: String, imageURL: String, completion: @escaping (apiResponse) -> Void) {
        
        let urlString = "\(Secrets.gtaURL)/deleteMyItem.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let parameterString = "createdBy=\(createdBy)&barcode=\(barcode)&imageURL=\(imageURL)&key=\(Secrets.gtaKey)"
            request.httpBody = parameterString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {

                                if let results = json["results"] {
                            
                                    if results == "1" {
                                        completion(.ok)
                                    } else if results == "-1" {
                                        completion(.failed)
                                    } else {
                                        completion(.noReply)
                                    }
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
    
    class func updateMyItem(createdBy: String, barcode: String, itemName: String, categoryID: Int, getAgain: GetAgain, listID: Int, completion: @escaping (apiResponse) -> Void) {
        if let itemNameEncoded = itemName.addingPercentEncoding(withAllowedCharacters: .urlUserAllowed) {
        
            let urlString = "\(Secrets.gtaURL)/updateMyItem.php"
            let url = URL(string: urlString)
            if let url = url {
                var request = URLRequest(url: url)
                
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Accept")
                request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                
                let parameterString = "createdBy=\(createdBy)&barcode=\(barcode)&itemName=\(itemNameEncoded)&categoryID=\(categoryID)&getAgain=\(getAgain.rawValue)&listID=\(listID)&key=\(Secrets.gtaKey)"
                request.httpBody = parameterString.data(using: .utf8)
                
                URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {
                                    if let results = json["results"] {
                                        if results == "1" || results == "0" {
                                            completion(.ok)
                                        } else if results == "-1" {
                                            completion(.failed)
                                        } else {
                                            completion(.noReply)
                                        }
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
    }
    
    class func getMerchantsFromAPI(barcode: String, completion: @escaping ([Merchant]) -> Void) {
        //let store = DataStore.sharedInstance
        let urlString = "\(Secrets.vigAPIURL)apiKey=\(Secrets.vigApiKey)&secret=\(Secrets.vigSecret)&country=us&itemsPerPage=10&sortBy=price&upc=\(barcode)"
        let url = URL(string: urlString)
        var merchants = [Merchant]()
        let merchantInstNotFound = Merchant(itemName: "", merchant: "notFound", country: "", price: 0, url: "")
        
        if let unwrappedUrl = url{
            let session = URLSession.shared
            let task = session.dataTask(with: unwrappedUrl) { (data, response, error) in
                
                if let unwrappedData = data {
                    do {
                        if let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                            // check the status code and create object
                            if let merchantCount = responseJSON["totalItems"] as? Int {
                                if merchantCount > 0 {
                                    if let items = responseJSON["items"] as? [[String:String]] {
                                        for itemDict in items {
                                            if let itemName = itemDict["name"], let merchant = itemDict["merchant"], let country = itemDict["country"], let priceString = itemDict["price"], let url = itemDict["url"] {
                                                
                                                if let price = Double(priceString) {
                                                    let merchantInst = Merchant(itemName: itemName, merchant: merchant, country: country, price: price, url: url)
                                                    merchants.append(merchantInst)
                                                }
                                                
                                            }
                                        }
                                    }
                                } else {
                                    //print("item not found, merchantInstNotFound will be used")
                                }
                            }
                        }
                        //let merchantInstUnwrapped = merchantInst ?? merchantInstNotFound
                        completion(merchants)
                    } catch {
                        print("An error occured when creating responseJSON")
                    }
                }
            }
            task.resume()
        }
    }
    
    class func getVigDataFromAPI(barcode: String, completion: @escaping (MyItem) -> Void) {
        let store = DataStore.sharedInstance
        let urlString = "\(Secrets.vigAPIURL)apiKey=\(Secrets.vigApiKey)&secret=\(Secrets.vigSecret)&country=us&itemsPerPage=1&sortBy=price&upc=\(barcode)"
        let url = URL(string: urlString)
        var itemInst: MyItem?
        if let createdBy = UserDefaults.standard.value(forKey: "userName") as? String {
            let itemInstNotFound = MyItem(createdBy: createdBy, barcode: "notFound", itemName: "", categoryID: 1, imageURL: "", listID: 0, getAgain: .unsure, merchants: 0)
            
            if let unwrappedUrl = url{
                let session = URLSession.shared
                let task = session.dataTask(with: unwrappedUrl) { (data, response, error) in
                    if let unwrappedData = data {
                        do {
                            if let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                                // check the status code and create object
                                if let merchants = responseJSON["totalItems"] as? Int {
                                    if merchants > 0 {
                                        if let items = responseJSON["items"] as? [[String:String]] {
                                            if let itemDict = items.first {
                                                if let itemName = itemDict["name"] {
                                                
                                                    itemInst = MyItem(createdBy: createdBy, barcode: barcode, itemName: itemName, categoryID: 0, imageURL: "", listID: 0, getAgain: .unsure, merchants: merchants)
                                                    
                                                    // set the imageURL and category values if we have them
                                                    if let itemInst = itemInst {
                                                        if let imageURL = itemDict["imageUrl"] {
                                                            itemInst.imageURL = imageURL
                                                        }
                                                        
                                                        if let category = itemDict["category"] {
                                                            // try to get the id for the category, if we dont have it generate a new id if we have it
                                                            // assign the id to the object
                                                            let categoryID = store.getCategoryIDFromLabel(label: category)
                                                            if categoryID == -1 {
                                                                // create a temp category for this label, prompt user on item detail page about
                                                                // keeping or discarding it
                                                                
                                                                if let createdBy = UserDefaults.standard.value(forKey: "userName") as? String {
                                                                    let tempCategory = MyCategory(createdBy: createdBy, id: -1, label: category)
                                                                    //print("New category: \(tempCategory.createdBy), \(tempCategory.id) , \(tempCategory.label)")
                                                                    store.myCategories.append(tempCategory)
                                                                }
                                                            }
                                                            itemInst.categoryID = categoryID
                                                        }
                                                    }

                                                }
                                            }
                                        }
                                    } else {
                                        //print("item not found, itemInstNotFound will be used")
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
    
    class func getEanDataFromAPI(barcode: String, completion: @escaping (MyItem) -> Void) {
        let store = DataStore.sharedInstance
        let urlString = "\(Secrets.eandataAPIURL)&keycode=\(Secrets.keyCode)&find=\(barcode)"
        let url = URL(string: urlString)
        var itemInst: MyItem?
        if let createdBy = UserDefaults.standard.value(forKey: "userName") as? String {
            let itemInstNotFound = MyItem(createdBy: createdBy, barcode: "notFound", itemName: "", categoryID: 1, imageURL: "", listID: 0, getAgain: .unsure, merchants: 0)
            
            if let unwrappedUrl = url{
                let session = URLSession.shared
                let task = session.dataTask(with: unwrappedUrl) { (data, response, error) in
                    if let unwrappedData = data {
                        do {
                            if let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any] {
                                // check the status code and create object
                                
                                let statusDict = responseJSON["status"] as! [String:String]
                                if let code = statusDict["code"] {
                                    if code == "200" {
                                        let productDict = responseJSON["product"] as! [String:Any]
                                        if productDict["attributes"] != nil {
                                            let productAttributesDict = productDict["attributes"] as! [String : String]
                                            
                                            // create the item object
                                            if let itemName = productAttributesDict["product"] {
                                                itemInst = MyItem(createdBy: createdBy, barcode: barcode, itemName: itemName, categoryID: 0, imageURL: "", listID: 0, getAgain: .unsure, merchants: 0)
                                                // set the imageURL and category values if we have them
                                                if let itemInst = itemInst {
                                                    if let imageURL = productDict["image"] as? String {
                                                        itemInst.imageURL = imageURL
                                                    }
                                                    
                                                    if let categoryText = productAttributesDict["category_text"] {
                                                        // try to get the id for the category, if we dont have it generate a new id if we have it
                                                        // assign the id to the object
                                                        let categoryID = store.getCategoryIDFromLabel(label: categoryText)
                                                        if categoryID == -1 {
                                                            // create a temp category for this label, prompt user on item detail page about
                                                            // keeping or discarding it
                                                            
                                                            if let createdBy = UserDefaults.standard.value(forKey: "userName") as? String {
                                                                let tempCategory = MyCategory(createdBy: createdBy, id: -1, label: categoryText)
                                                                //print("New category:\(tempCategory.createdBy), \(tempCategory.id) , \(tempCategory.label)")
                                                                store.myCategories.append(tempCategory)
                                                            }
                                                        }
                                                        itemInst.categoryID = categoryID
                                                    }
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
    
    class func selectMyItems(createdBy: String, completion: @escaping (Bool) -> Void) {
        
        let store = DataStore.sharedInstance
        let urlString = "\(Secrets.gtaURL)/selectMyItems.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let parameterString = "key=\(Secrets.gtaKey)&createdBy=\(createdBy)"
            request.httpBody = parameterString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let unwrappedData = data {
                    do {
                        
                        store.myItems.removeAll()
                        store.myCategories.removeAll()
                        store.myLists.removeAll()
                        store.otherCategories.removeAll()
                        store.otherItems.removeAll()
                        
                        let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any]
                        if let responseJSON = responseJSON {
                            
                            if let myListsDictAny = responseJSON["myLists"] {
                                let myListsDict = myListsDictAny as! [[String:String]]
                                for myListDict in myListsDict {
                                    //unwrap the incoming data and create item objects in datastore
                                    if let listIDString = myListDict["id"], let listLabelEncoded = myListDict["label"]{
                                        
                                        if let listID = Int(listIDString) {
                                            
                                            // clean html from the label
                                            let listLabel = self.decodeCharactersIn(string: listLabelEncoded)
                                            
                                            // create the object and add to datastore
                                            let myListInst = MyList(id: listID, label: listLabel)
                                            store.myLists.append(myListInst)
                                        }
                                    }
                                }
                            } // end myListsDictAny
                            
                            if let myCategoriesDictAny = responseJSON["myCategories"] {
                                let myCategoriesDict = myCategoriesDictAny as! [[String:String]]
                                
                                for myCategoryDict in myCategoriesDict {

                                    //unwrap the incoming data and create item objects in datastore
                                    if let categoryCreatedBy = myCategoryDict["createdBy"], let categoryIDString = myCategoryDict["id"], let categoryLabelEncoded = myCategoryDict["label"] {
                                        
                                        if let categoryID = Int(categoryIDString) {
                                           
                                            // clean html from the label
                                            let categoryLabel = self.decodeCharactersIn(string: categoryLabelEncoded)
                                        
                                            // create the object and add to datastore
                                            let categoryInst = MyCategory(createdBy: categoryCreatedBy, id: categoryID, label: categoryLabel)
                                            
                                            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                                                userName == categoryInst.createdBy ? store.myCategories.append(categoryInst) : store.otherCategories.append(categoryInst)
                                            }
                                        }
                                    }
                                }
                            } // end myCategoriesDictAny
                            
                            if let myItemsDictAny = responseJSON["myItems"] {
                                let myItemsDict = myItemsDictAny as! [[String:String]]
                                var myItemsUnsorted = [MyItem]()
                                
                                for myItemDict in myItemsDict {
                                    
                                    //unwrap the incoming data and create item objects in datastore
                                    if let createdBy = myItemDict["createdBy"],
                                        let barcode = myItemDict["barcode"],
                                        let itemNameEncoded = myItemDict["itemName"],
                                        let categoryIDString = myItemDict["categoryID"],
                                        let imageURL = myItemDict["imageURL"],
                                        let listIDString = myItemDict["listID"],
                                        let getAgainString = myItemDict["getAgain"],
                                        let merchantsString = myItemDict["merchants"] {
                                    
                                        // clean html from the name
                                        let itemName = self.decodeCharactersIn(string: itemNameEncoded)
                                        
                                        if let categoryID = Int(categoryIDString), let listID = Int(listIDString), let merchants = Int(merchantsString) {
                                        
                                            // getAgain
                                            var getAgain: GetAgain!
                                        
                                            switch getAgainString {
                                            case "yes":
                                                getAgain = GetAgain.yes
                                            case "no":
                                                getAgain = GetAgain.no
                                            default:
                                                getAgain = GetAgain.unsure
                                            }
                                        
                                            let itemInst = MyItem(createdBy: createdBy, barcode: barcode, itemName: itemName, categoryID: categoryID, imageURL: imageURL, listID: listID, getAgain: getAgain, merchants: merchants)
                                            
                                            // create an array of the user's items and an array for the other items.
                                            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                                                userName == itemInst.createdBy ? myItemsUnsorted.append(itemInst) : store.otherItems.append(itemInst)
                                            }
                                        }
                                    }
                                    store.myItems = myItemsUnsorted.sorted(by: { $0.itemName < $1.itemName })
                                }
                            } // end myItemsDictAny
                        }
                        completion(true)
                    } catch {
                        completion(false) // An error occurred when creating responseJSON
                    }
                }
            }).resume()
        }
    }
    
    class func getAccessList(completion: @escaping (Bool) -> Void) {
        
        let store = DataStore.sharedInstance
        let urlString = "\(Secrets.gtaURL)/selectAccessList.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            // get the userName and then set the parameters
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                let parameterString = "key=\(Secrets.gtaKey)&userName=\(userName)"
                request.httpBody = parameterString.data(using: .utf8)
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let unwrappedData = data {
                    do {
                        store.accessList.removeAll()
                        let responseJSON = try JSONSerialization.jsonObject(with: unwrappedData, options: []) as? [String: Any]
                        if let responseJSON = responseJSON {
                            // accessList
                            if let accessListDictAny = responseJSON["accessList"] {
                                let accessListDict = accessListDictAny as! [[String:String]]
                                for accessRecordDict in accessListDict {
                                    if let listIDString = accessRecordDict["listID"], let listOwner = accessRecordDict["listOwner"], let listViewer = accessRecordDict["listViewer"], let status = accessRecordDict["status"] {
                                        if let listID = Int(listIDString) {
                                            let accessRecordInst = AccessRecord(id: listID, owner: listOwner, viewer: listViewer, status: status)
                                            store.accessList.append(accessRecordInst)
                                        }
                                    }
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
    
    class func handleAccessRecord(action: String, listID: Int, listOwner: String, listViewer: String, status: String, completion: @escaping (apiResponse) -> Void) {
        
        let urlString = "\(Secrets.gtaURL)/handleAccessRecord.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            
            let parameterString = "key=\(Secrets.gtaKey)&action=\(action)&listID=\(listID)&listOwner=\(listOwner)&listViewer=\(listViewer)&status=\(status)"
            request.httpBody = parameterString.data(using: .utf8)
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Int] {
                            if let results = json["results"] {
                                if results == 1 {
                                    completion(.ok)
                                } else if results == -1 {
                                    completion(.failed)
                                } else {
                                    completion(.noReply)
                                }
                            }
                        }
                    } catch {
                        completion(.noReply)
                    }
                }
            }).resume()
        }
    }
    
    class func insertMyCategory(category: MyCategory, completion: @escaping (apiResponse) -> Void) {
        
        let urlString = "\(Secrets.gtaURL)/insertMyCategory.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            // set the parameters
            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                let parameterString = "createdBy=\(userName)&id=\(category.id)&label=\(category.label)&key=\(Secrets.gtaKey)"
                request.httpBody = parameterString.data(using: .utf8)
            }

            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                if let results = json["results"] as! Int? {
                                    if results == 1 {
                                        completion(.ok)
                                    } else if results == -1 {
                                        completion(.failed)
                                    } else {
                                        completion(.noReply)
                                    }
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

    class func deleteMyCategory(id: Int, completion: @escaping (apiResponse) -> Void) {
        
        let urlString = "\(Secrets.gtaURL)/deleteMyCategory.php"
        let url = URL(string: urlString)
        if let url = url {
            var request = URLRequest(url: url)
            
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

            if let userName = UserDefaults.standard.value(forKey: "userName") as? String {
                let parameterString = "createdBy=\(userName)&id=\(id)&key=\(Secrets.gtaKey)"
                request.httpBody = parameterString.data(using: .utf8)
            }
            
            URLSession.shared.dataTask(with: request, completionHandler: { data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : String] {
                                if let results = json["results"] {
                                    if results == "1" {
                                        completion(.ok)
                                    } else if results == "-1" {
                                        completion(.failed)
                                    } else {
                                        completion(.noReply)
                                    }
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

    static func decodeCharactersIn(string: String) -> String {
        var string = string; string = string.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
        let characters = ["&#8217;" : "'", "&#8220;": "“", "[&hellip;]": "...", "&#038;": "&", "&#8230;": "...", "&#039;": "'", "&quot;": "“", "%20": " ", "&gt;": ">"]
        for (code, character) in characters {
            string = string.replacingOccurrences(of: code, with: character, options: .caseInsensitive, range: nil)
        }
        return string
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

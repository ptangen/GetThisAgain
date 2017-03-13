//
//  ItemDetailViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import SDWebImage

class ItemDetailViewController: UITabBarController, ItemDetailViewDelegate {
    
    let store = DataStore.sharedInstance
    let itemDetailViewInst = ItemDetailView()
    var itemExistsInDatastore = Bool()
    var itemInst: MyItem!
    var itemInstImage: UIImage?
    var addButton = UIBarButtonItem()
    var cancelButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()
    var deleteButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.itemDetailViewInst.delegate = self
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        
        // add button
        self.addButton.style = .plain
        self.addButton.target = self
        self.addButton.action = #selector(addButtonClicked)
        self.addButton.title = "Add Item"
        
        // cancel button
        self.cancelButton.style = .plain
        self.cancelButton.target = self
        self.cancelButton.action = #selector(cancelButtonClicked)
        self.cancelButton.title = "Cancel"
        
        // done button
        self.doneButton.style = .plain
        self.doneButton.target = self
        self.doneButton.title = "Done"
        self.doneButton.action = #selector(doneButtonClicked)
        
        // delete button
        self.deleteButton.style = .plain
        self.deleteButton.target = self
        self.deleteButton.title = "Delete"
        self.deleteButton.action = #selector(deleteButtonClicked)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemDetailViewInst.itemInst = itemInst
        self.title = "Item Detail" // nav bar title
        
        self.itemDetailViewInst.nameLabel.text = itemInst.name
        self.itemDetailViewInst.categoryLabel.text = itemInst.category.rawValue
        self.itemDetailViewInst.shoppingListSwitch.isOn = itemInst.shoppingList
        
        if self.itemExistsInDatastore {
            // done button
            self.navigationItem.rightBarButtonItems = [doneButton]
            // delete button
            self.navigationItem.leftBarButtonItems = [deleteButton]
        } else {
            // add button
            self.navigationItem.rightBarButtonItems = [addButton]
            // cancel button
            self.navigationItem.setHidesBackButton(true, animated:false);
            
            self.navigationItem.leftBarButtonItems = [cancelButton]
        }

        if let itemInstImage = self.itemInstImage {
            // image came from a snapshot
            self.itemDetailViewInst.itemImageView.image = itemInstImage
        } else {
            if itemInst.imageURL.isEmpty {
                // show no image found
                self.itemDetailViewInst.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
            } else {
                // show the image per the URL
                let itemImageURL = URL(string: itemInst.imageURL)
                self.itemDetailViewInst.itemImageView.sd_setImage(with: itemImageURL)
            }
        }

        self.itemDetailViewInst.itemImageView.contentMode = .scaleAspectFit
        
        // set the getThisAgainControl
        switch itemInst.getAgain.label() {
        case "No" :
            self.itemDetailViewInst.getAgainPicker.selectedSegmentIndex = 0
        case "Unsure" :
            self.itemDetailViewInst.getAgainPicker.selectedSegmentIndex = 1
        case "Yes" :
            self.itemDetailViewInst.getAgainPicker.selectedSegmentIndex = 2
        default:
            break
        }
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.itemDetailViewInst.frame = CGRect.zero
        self.view = self.itemDetailViewInst
    }

    func addButtonClicked() {
        if let itemInst = self.itemInst {
            APIClient.insertMyItem(itemInst: itemInst, image: self.itemInstImage) { (results, imageURL, barcode) in
                if results == apiResponse.ok {
                    itemInst.barcode = barcode
                    itemInst.imageURL = imageURL
                    self.store.myItems.append(itemInst)
                    self.doneButtonClicked()
                } else {
                    print("error")
                }
            }
        }
    }
    
    func deleteButtonClicked() {
        if let itemInst = self.itemInst {
            APIClient.deleteMyItem(userName: UserDefaults.standard.value(forKey: "username") as! String, barcode: itemInst.barcode, imageURL: itemInst.imageURL) { (results) in
                if results == apiResponse.ok {
                    self.store.myItems = self.store.myItems.filter { $0.barcode != itemInst.barcode } // remove the item from the datastore
                    self.doneButtonClicked()
                } else {
                    print("error")
                }
            }
        }
    }

    func doneButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func cancelButtonClicked() {
        let itemsTabViewControllerInst = ItemsTabViewController()
        self.navigationController?.pushViewController(itemsTabViewControllerInst, animated: false)
    }
    
    func openEditName(item: MyItem) {
        let editNameViewControllerInst = EditNameViewController()
        //editNameViewControllerInst.editNameViewInst.itemInst = item
        self.navigationController?.pushViewController(editNameViewControllerInst, animated: false)
    }
}

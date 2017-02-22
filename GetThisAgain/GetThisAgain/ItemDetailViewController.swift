//
//  ItemDetailViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/19/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit
import SDWebImage

class ItemDetailViewController: UITabBarController {
    
    let store = DataStore.sharedInstance
    let itemDetailViewInst = ItemDetailView()
    var editMode = Bool()
    var itemInst: Item!
    var saveButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        
        // save button
        self.saveButton.style = .plain
        self.saveButton.target = self
        self.saveButton.action = #selector(saveButtonClicked)
        self.navigationItem.rightBarButtonItems = [saveButton]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemDetailViewInst.itemInst = itemInst
        self.title = "Item Detail" // nav bar title
        self.itemDetailViewInst.nameLabel.text = self.itemInst.name
        self.itemDetailViewInst.categoryLabel.text = self.itemInst.category
        self.itemDetailViewInst.shoppingListSwitch.isOn = self.itemInst.shoppingList
        self.editMode ? (self.saveButton.title = "Done") : (self.saveButton.title = "Add Item")
        
        let itemImageURL = URL(string: self.itemInst.imageURL)
        self.itemDetailViewInst.itemImageView.sd_setImage(with: itemImageURL)
        self.itemDetailViewInst.itemImageView.contentMode = .scaleAspectFit
        
        // add cancel button to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelButtonClicked))
        self.editMode ? () : (self.navigationItem.leftBarButtonItems = [cancelButton])
        
        // set the getThisAgainControl
        switch self.itemInst.getThisAgain.label() {
        case "No" :
            self.itemDetailViewInst.getThisAgainPicker.selectedSegmentIndex = 0
        case "Unsure" :
            self.itemDetailViewInst.getThisAgainPicker.selectedSegmentIndex = 1
        case "Yes" :
            self.itemDetailViewInst.getThisAgainPicker.selectedSegmentIndex = 2
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
    
    func compareItems(selectedItem : Item) -> Bool {
        if let itemInst = self.itemInst {
            return selectedItem.barcode == itemInst.barcode
        }
        return false
    }

    func saveButtonClicked() {
    
        if !self.store.myItems.contains(where: compareItems) {
            self.store.myItems.append(self.itemInst) // item does not exist in myItems, so add it
        }
        
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
}

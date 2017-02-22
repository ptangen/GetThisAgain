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
    var addButton = UIBarButtonItem()
    var doneButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []   // prevents view from siding under nav bar
        
        // add button
        self.addButton.style = .plain
        self.addButton.target = self
        self.addButton.action = #selector(addButtonClicked)
        self.addButton.title = "Add Item"
        
        // done button
        self.doneButton.style = .plain
        self.doneButton.target = self
        self.doneButton.title = "Done"
        self.doneButton.action = #selector(doneButtonClicked)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.itemDetailViewInst.itemInst = itemInst
        self.title = "Item Detail" // nav bar title
        self.itemDetailViewInst.nameLabel.text = self.itemInst.name
        self.itemDetailViewInst.categoryLabel.text = self.itemInst.category
        self.itemDetailViewInst.shoppingListSwitch.isOn = self.itemInst.shoppingList
        self.editMode ? (self.navigationItem.rightBarButtonItems = [doneButton]) : (self.navigationItem.rightBarButtonItems = [addButton])
        
       // var imageURLString = String()
        if self.itemInst.imageURL.isEmpty {
            // show no image found
            self.itemDetailViewInst.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
        } else {
            // show the image per the URL
            let itemImageURL = URL(string: self.itemInst.imageURL)
            self.itemDetailViewInst.itemImageView.sd_setImage(with: itemImageURL)
        }
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

    func addButtonClicked() {
        self.store.myItems.append(self.itemInst)
        self.doneButtonClicked()
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
}

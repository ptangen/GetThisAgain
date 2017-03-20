//
//  ShoppingListViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/20/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController, ShoppingListViewDelegate {
    
    let store = DataStore.sharedInstance
    var shoppingListViewInst = ShoppingListView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.shoppingListViewInst.delegate = self
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.shoppingListViewInst.frame = CGRect.zero
        self.view = self.shoppingListViewInst
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Shopping List"
        var shoppingListUnsorted = [MyItem]()
        
        // iterate through myItems and place the items that are on a list into the shoppingListItems array
        for list in self.store.myLists {
            // myItems
            let myItemsFromAList = self.store.myItems.filter({ $0.listID == list.id })
            shoppingListUnsorted.append(contentsOf: myItemsFromAList)
            // other items
            let otherItemsFromAList = self.store.otherItems.filter({ $0.listID == list.id })
            shoppingListUnsorted.append(contentsOf: otherItemsFromAList)
        }
        self.shoppingListViewInst.shoppingListItems = shoppingListUnsorted.sorted(by: { $0.itemName < $1.itemName })
    }
    
    func openItemDetail(item: MyItem) {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.itemInst = item
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

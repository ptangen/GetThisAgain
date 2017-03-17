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
        if let myList = self.store.myLists.first {
            self.shoppingListViewInst.shoppingListItems = self.store.myItems.filter({ $0.listID == myList.id })
            // we only have one list now and there is no sharing so if the ID is greater than 1 it is in our list.
            // we need to show items from our shopping list that belong to other people...
            // we need to get the IDs of our lists and the shared lists
        }
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

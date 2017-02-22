//
//  ShoppingListViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/20/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ShoppingListViewController: UIViewController, ScanViewDelegate {
    
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
        self.shoppingListViewInst.shoppingListItems = self.store.myItems.filter({ $0.shoppingList == true })
    }
    
    func openItemDetail(item: Item, editMode: Bool) {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.editMode = true
        itemDetailViewControllerInst.itemInst = item
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//
//  MyItemsViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class MyItemsViewController: UIViewController, MyItemsViewDelegate {
    
    //weak var delegate: MyItemsViewControllerDelegate?
    let store = DataStore.sharedInstance
    var myItemsViewInst = MyItemsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myItemsViewInst.delegate = self
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.myItemsViewInst.frame = CGRect.zero
        self.view = self.myItemsViewInst
    }
    
    func showAlertMessage(_ message: String) {
        Utilities.showAlertMessage(message, viewControllerInst: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "My Items"
        // get myItems
        if self.store.myItems.isEmpty && !UserDefaults.standard.bool(forKey: "mostRecentTabIsShoppingList") {
            self.store.getMyItemsFromDB(currentViewController: self, type: "MyItems")
            self.myItemsViewInst.showActivityIndicator(uiView: self.myItemsViewInst)
        }
        self.myItemsViewInst.myItemsTableView.reloadData()
    }
    
    func openItemDetail(item: MyItem) {
        let itemDetailViewControllerInst = ItemDetailViewController()
        itemDetailViewControllerInst.itemInst = item
        self.navigationController?.pushViewController(itemDetailViewControllerInst, animated: false)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

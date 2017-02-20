//
//  MyItemsViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class MyItemsViewController: UIViewController, ScanViewDelegate {
    
    let store = DataStore.sharedInstance
    var myItemsViewInst = MyItemsView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.myItemsViewInst.delegate = self
        store.myItems.isEmpty ? self.store.getSampleData() : ()
    }
    
    override func loadView(){
        // hide nav bar on login page
        self.navigationController?.setNavigationBarHidden(false, animated: .init(true))
        self.myItemsViewInst.frame = CGRect.zero
        self.view = self.myItemsViewInst
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "My Items"
    }
    
    func openItemDetail(item: Item) {
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

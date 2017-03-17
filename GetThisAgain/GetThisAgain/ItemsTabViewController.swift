//
//  ItemsTabViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ItemsTabViewController: UITabBarController, UITabBarControllerDelegate  {
    
    let store = DataStore.sharedInstance
    let myItemsViewControllerInst = MyItemsViewController()
    let shoppingListViewControllerInst = ShoppingListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        self.title = "Get This Again"
        self.navigationItem.hidesBackButton = true
        UITabBar.appearance().tintColor = UIColor(named: .statusBarBlue)
        self.automaticallyAdjustsScrollViewInsets = false
        
        // Create MyItems Tab
        let tabMyItems = UITabBarItem(title: "My Items", image: UIImage(named: "person"), selectedImage: UIImage(named: "person"))
        self.myItemsViewControllerInst.tabBarItem = tabMyItems
        
        // Create ShoppingList Tab
        let tabShoppingList = UITabBarItem(title: "Shopping List", image: UIImage(named: "shoppingCart"), selectedImage: UIImage(named: "shoppingCart"))
        self.shoppingListViewControllerInst.tabBarItem = tabShoppingList
        
        self.viewControllers = [self.myItemsViewControllerInst, self.shoppingListViewControllerInst]
        
        // add controls to nav bar
        self.navigationItem.setHidesBackButton(true, animated:false);
        
        let addButton = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonClicked))
        self.navigationItem.rightBarButtonItems = [addButton]
        
        let menuButton = UIBarButtonItem(image: #imageLiteral(resourceName: "menu"), style: .plain, target: self, action: #selector(menuButtonClicked))
        self.navigationItem.leftBarButtonItems = [menuButton]
    }
    
    func addButtonClicked() {
        let captureItemViewControllerInst = CaptureItemViewController()
        self.navigationController?.pushViewController(captureItemViewControllerInst, animated: true) // show destination with nav bar
    }
    
    func menuButtonClicked(sender: UIBarButtonItem) {
        
        let optionMenu = UIAlertController(title: nil, message: "Menu", preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "Sign Out", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.store.myItems.removeAll()
            self.store.myCategories.removeAll()
            self.store.myLists.removeAll()
            let signInControllerInst = SignInViewController()
            self.navigationController?.pushViewController(signInControllerInst, animated: true) // show destination with nav bar
        })
        
        let addAction = UIAlertAction(title: "Add Item", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            self.addButtonClicked()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        // Add actions to menu and display
        optionMenu.addAction(addAction)
        optionMenu.addAction(signOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}

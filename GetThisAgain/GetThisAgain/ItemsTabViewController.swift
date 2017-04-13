//
//  ItemsTabViewController.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ItemsTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    let store = DataStore.sharedInstance
    let myItemsViewControllerInst = MyItemsViewController()
    let shoppingListViewControllerInst = ShoppingListViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(false)
        // open most recently used tab
        UserDefaults.standard.bool(forKey: "mostRecentTabIsShoppingList") ? (self.selectedIndex = 1) : (self.selectedIndex = 0)
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {

    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {

        // save mostRecentTabIsShoppingList in user prefs so when the user visits the tabs again it will show the most recently used tab
        self.selectedIndex == 0 ? UserDefaults.standard.setValue(false, forKey: "mostRecentTabIsShoppingList") : UserDefaults.standard.setValue(true, forKey: "mostRecentTabIsShoppingList")
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
            self.store.otherCategories.removeAll()
            self.store.otherItems.removeAll()
            self.store.accessList.removeAll()
            let signInControllerInst = SignInViewController()
            self.navigationController?.pushViewController(signInControllerInst, animated: true) // show destination with nav bar
        })
        
        let openSharing = UIAlertAction(title: "Sharing Shopping Lists", style: .default, handler: { (alert: UIAlertAction!) -> Void in
            let sharingTabViewControllerInst = SharingTabViewController()
            self.navigationController?.pushViewController(sharingTabViewControllerInst, animated: true) // show destination with nav bar
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { (alert: UIAlertAction!) -> Void in })
        
        // Add actions to menu and display
        optionMenu.addAction(openSharing)
        optionMenu.addAction(signOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
}

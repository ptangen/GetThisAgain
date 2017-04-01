//
//  ShoppingListView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/21/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol ShoppingListViewDelegate: class {
    func openItemDetail(item: MyItem)
    func generateShoppingList()
    func showAlertMessage(_: String)
}

class ShoppingListView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: ShoppingListViewDelegate?
    let store = DataStore.sharedInstance
    var shoppingListItems = [MyItem]()
    var filteredItems = [MyItem]()
    let shoppingListTableView = UITableView()
    var shoppingListTableViewInstYConstraintWithHeading = NSLayoutConstraint()
    var shoppingListTableViewInstYConstraintWithoutHeading = NSLayoutConstraint()
    var shoppingListViewCount = Int()
    let activityIndicator = UIView()
    // the activity indicator blocks the tap event so we have to move it off to the side when hidden
    var activityIndicatorXConstraintWhileHidden = NSLayoutConstraint()
    var activityIndicatorXConstraintWhileDisplayed = NSLayoutConstraint()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        // barcodeType: .EAN13,
        
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        self.shoppingListTableView.register(ItemsTableViewCell.self, forCellReuseIdentifier: "prototype")
        
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false
        self.searchController.dimsBackgroundDuringPresentation = false
        self.shoppingListTableView.tableHeaderView = self.searchController.searchBar
        
        self.pageLayout()
    }
    
    // tableview config
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != "" {
            return filteredItems.count
        }
        return self.shoppingListItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ItemsTableViewCell(style: .default, reuseIdentifier: "prototype")
        var shoppingItemCurrent: MyItem
        if searchController.isActive && searchController.searchBar.text != "" {
            shoppingItemCurrent = self.filteredItems[indexPath.row]
        } else {
            shoppingItemCurrent = self.shoppingListItems[indexPath.row]
        }
        
        // set the title and subtitle
        cell.titleLabel.text = shoppingItemCurrent.itemName
        cell.subTitleLabel.text = self.store.getCategoryLabelFromID(id: shoppingItemCurrent.categoryID)
        
        // set the icon for the getAgain status
        switch shoppingItemCurrent.getAgain.rawValue {
        case "yes" :
            cell.getThisAgainLabel.text = Constants.iconLibrary.faCheckCircle.rawValue
            cell.getThisAgainLabel.textColor = UIColor(named: .statusGreen)
        case "no" :
            cell.getThisAgainLabel.text = Constants.iconLibrary.faTimesCircle.rawValue
            cell.getThisAgainLabel.textColor = UIColor(named: .statusRed)
        default:
            cell.getThisAgainLabel.text = Constants.iconLibrary.faQuestionCircle.rawValue
            cell.getThisAgainLabel.textColor = UIColor(named: .disabledText)
        }
        
        // set the image
        if shoppingItemCurrent.imageURL.isEmpty {
            // show no image found
            cell.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
        } else {
            // show the image per the URL
            let itemImageURL = URL(string: shoppingItemCurrent.imageURL)
            cell.itemImageView.sd_setImage(with: itemImageURL)
        }
        cell.itemImageView.contentMode = .scaleAspectFit
        
        // if items on the shopping list come from multiple people, show the userName for each item
        let otherItemsOnShoppingList = self.store.otherItems.filter( { $0.listID != 0 } )
        if !otherItemsOnShoppingList.isEmpty {
            cell.userNameLabel.text = shoppingItemCurrent.createdBy
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            self.delegate?.openItemDetail(item: self.filteredItems[indexPath.row])
        } else {
            self.delegate?.openItemDetail(item: self.shoppingListItems[indexPath.row])
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        // removeButton
        let removeButton: UITableViewRowAction = UITableViewRowAction(style: .normal, title: "Remove from Shopping List") { (action, index) -> Void in
            
            tableView.isEditing = false
            self.showActivityIndicator(uiView: self)
            
            // get the approriate item inst
            var itemInst: MyItem!
            if self.searchController.isActive && self.searchController.searchBar.text != "" {
                itemInst = self.filteredItems[indexPath.row]
            } else {
                itemInst = self.shoppingListItems[indexPath.row]
            }
            
            // set listID to 0 on the server
            APIClient.updateMyItem(createdBy: itemInst.createdBy, barcode: itemInst.barcode, itemName: itemInst.itemName, categoryID: itemInst.categoryID, getAgain: itemInst.getAgain, listID: 0, completion: { (results) in
                
                self.activityIndicatorXConstraintWhileHidden.isActive = true
                self.activityIndicatorXConstraintWhileDisplayed.isActive = false
                if results == apiResponse.ok {
                    if self.searchController.isActive && self.searchController.searchBar.text != "" {
                        itemInst.listID = 0
                        self.filteredItems.remove(at: indexPath.row)
                        self.shoppingListTableView.reloadData()
                        if let delegate = self.delegate {
                            delegate.generateShoppingList() // regenerate the shopping list
                        }
                    } else {
                        itemInst.listID = 0
                        self.shoppingListItems.remove(at: indexPath.row)
                        self.shoppingListTableView.reloadData()
                    }
                } else {
                    if let delegate = self.delegate {
                        delegate.showAlertMessage("The system cannot remove this item from the shopping list. Please forward this message to ptangen@ptangen.com")
                    }
                }
            })
        }
        removeButton.backgroundColor = UIColor(named: .statusGreen)
        return [removeButton]
    }

    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        self.filteredItems = self.shoppingListItems.filter { shoppingItem in
            var nameAndCategory = String()
            nameAndCategory = shoppingItem.itemName + self.store.getCategoryLabelFromID(id: shoppingItem.categoryID)
            return nameAndCategory.lowercased().contains(searchText.lowercased())
        }
        self.shoppingListTableView.reloadData()
    }
    
    func pageLayout() {
        
        // myItemsTableView
        self.addSubview(self.shoppingListTableView)
        self.shoppingListTableView.translatesAutoresizingMaskIntoConstraints = false
        self.shoppingListTableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 64).isActive = true
        self.shoppingListTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
        self.shoppingListTableView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.shoppingListTableView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        // activityIndicator
        self.addSubview(self.activityIndicator)
        self.activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.activityIndicatorXConstraintWhileHidden = self.activityIndicator.centerXAnchor.constraint(equalTo: self.leftAnchor, constant: -40)
        self.activityIndicatorXConstraintWhileDisplayed = self.activityIndicator.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        self.activityIndicatorXConstraintWhileHidden.isActive = true
        self.activityIndicatorXConstraintWhileDisplayed.isActive = false
        self.activityIndicator.heightAnchor.constraint(equalToConstant: 80).isActive = true
        self.activityIndicator.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        self.activityIndicator.widthAnchor.constraint(equalToConstant: 80).isActive = true
    }
    
    func showActivityIndicator(uiView: UIView) {
        self.activityIndicatorXConstraintWhileHidden.isActive = false
        self.activityIndicatorXConstraintWhileDisplayed.isActive = true
        
        self.activityIndicator.backgroundColor = UIColor(named: .blue)
        self.activityIndicator.layer.cornerRadius = 10
        self.activityIndicator.clipsToBounds = true
        
        let actInd: UIActivityIndicatorView = UIActivityIndicatorView()
        actInd.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        actInd.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        actInd.center = CGPoint(x: 40, y: 40)
        
        self.activityIndicator.addSubview(actInd)
        actInd.startAnimating()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension ShoppingListView: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = self.searchController.searchBar.text {
            self.filterContentForSearchText(searchText: searchText)
        }
    }
}

//
//  ShoppingListView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/21/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ShoppingListView: UIView, UITableViewDataSource, UITableViewDelegate {

    weak var delegate: ScanViewDelegate?
    let store = DataStore.sharedInstance
    var shoppingListItems = [Item]()
    var filteredItems = [Item]()
    let shoppingListTableView = UITableView()
    var shoppingListTableViewInstYConstraintWithHeading = NSLayoutConstraint()
    var shoppingListTableViewInstYConstraintWithoutHeading = NSLayoutConstraint()
    var shoppingListViewCount = Int()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        // barcodeType: .EAN13,
        
        self.shoppingListTableView.delegate = self
        self.shoppingListTableView.dataSource = self
        self.shoppingListTableView.register(ShoppingListTableViewCell.self, forCellReuseIdentifier: "prototype")
        
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
        let cell = ShoppingListTableViewCell(style: .default, reuseIdentifier: "prototype")
        var shoppingItemCurrent: Item
        if searchController.isActive && searchController.searchBar.text != "" {
            shoppingItemCurrent = self.filteredItems[indexPath.row]
        } else {
            shoppingItemCurrent = self.shoppingListItems[indexPath.row]
        }
        
        cell.titleLabel.text = shoppingItemCurrent.name  + " (" + shoppingItemCurrent.getThisAgain.label() + ")"
        cell.subTitleLabel.text = shoppingItemCurrent.category
        
        let itemImageURL = URL(string: shoppingItemCurrent.imageURL)
        cell.itemImageView.sd_setImage(with: itemImageURL)
        cell.itemImageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            self.delegate?.openItemDetail(item: self.filteredItems[indexPath.row], editMode: true)
        } else {
            self.delegate?.openItemDetail(item: self.shoppingListItems[indexPath.row], editMode: true)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        self.filteredItems = self.shoppingListItems.filter { shoppingItem in
            var nameAndCategory = String()
            nameAndCategory = shoppingItem.name + shoppingItem.category
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

//
//  MyItemsView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol MyItemsViewDelegate: class {
    func openDetail(_: Item)
    func showAlertMessage(_: String)
}

class MyItemsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: MyItemsViewDelegate?
    var filteredItems = [Item]()
    var myItems = [Item]()
    let myItemsTableView = UITableView()
    var myItemsTableViewInstYConstraintWithHeading = NSLayoutConstraint()
    var myItemsTableViewInstYConstraintWithoutHeading = NSLayoutConstraint()
    var myItemsViewCount = Int()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        //self.store.getEquitiesMetadataFromCoreData()
        let myItem1 = Item(barcode: 0073852009385, barcodeType: .EAN13, name: "Purell H/Sanit Gel Aloe 2oz", categoryText: "Bath / Beauty / Hygiene", imageURL: "http://eandata.com/image/products/007/385/200/0073852009385.jpg", shoppingList: false)
        self.myItems.append(myItem1)
        
        self.myItemsTableView.delegate = self
        self.myItemsTableView.dataSource = self
        self.myItemsTableView.register(MyItemsTableViewCell.self, forCellReuseIdentifier: "prototype")
        self.myItemsTableView.separatorColor = UIColor.clear
        self.myItemsTableView.backgroundColor = UIColor.yellow
        
        self.searchController.searchResultsUpdater = self
        self.searchController.dimsBackgroundDuringPresentation = false
        self.myItemsTableView.tableHeaderView = self.searchController.searchBar
        
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
        return self.myItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MyItemsTableViewCell(style: .default, reuseIdentifier: "prototype")
        var myItemCurrent: Item
        if searchController.isActive && searchController.searchBar.text != "" {
            myItemCurrent = self.filteredItems[indexPath.row]
        } else {
            myItemCurrent = self.myItems[indexPath.row]
        }
        
        cell.titleLabel.text = myItemCurrent.name
        cell.subTitleLabel.text = myItemCurrent.categoryText
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive && searchController.searchBar.text != "" {
            self.delegate?.openDetail(self.filteredItems[indexPath.row])
        } else {
            self.delegate?.openDetail(self.myItems[indexPath.row])
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        
        // hide/show labels about company count above the tableview when search is being used
        if self.myItemsTableViewInstYConstraintWithHeading.isActive {
            self.myItemsTableViewInstYConstraintWithHeading.isActive = false
            self.myItemsTableViewInstYConstraintWithoutHeading.isActive = true
        } else {
            self.myItemsTableViewInstYConstraintWithHeading.isActive = true
            self.myItemsTableViewInstYConstraintWithoutHeading.isActive = false
        }
        
        self.filteredItems = self.myItems.filter { myItem in
            var nameAndCategory = String()
            nameAndCategory = myItem.name + myItem.categoryText
            return nameAndCategory.lowercased().contains(searchText.lowercased())
        }
        self.myItemsTableView.reloadData()
    }
    
    func pageLayout() {
        
        // myItemsTableView
        self.addSubview(self.myItemsTableView)
        self.myItemsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.myItemsTableViewInstYConstraintWithHeading = self.myItemsTableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        self.myItemsTableViewInstYConstraintWithHeading.isActive = true
        self.myItemsTableViewInstYConstraintWithoutHeading = self.myItemsTableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 0)
        self.myItemsTableViewInstYConstraintWithoutHeading.isActive = false
        self.myItemsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
        self.myItemsTableView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.myItemsTableView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}

extension MyItemsView: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = self.searchController.searchBar.text {
            self.filterContentForSearchText(searchText: searchText)
        }
    }
}


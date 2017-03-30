//
//  MyItemsView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol MyItemsViewDelegate: class {
    func openItemDetail(item: MyItem)
    func showAlertMessage(_: String)
}

class MyItemsView: UIView, UITableViewDataSource, UITableViewDelegate {
    
    weak var delegate: MyItemsViewDelegate?
    let store = DataStore.sharedInstance
    var filteredItems = [MyItem]()
    let myItemsTableView = UITableView()
    var myItemsTableViewInstYConstraintWithHeading = NSLayoutConstraint()
    var myItemsTableViewInstYConstraintWithoutHeading = NSLayoutConstraint()
    var myItemsViewCount = Int()
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override init(frame:CGRect){
        super.init(frame: frame)
        // barcodeType: .EAN13,
        
        self.myItemsTableView.delegate = self
        self.myItemsTableView.dataSource = self
        self.myItemsTableView.register(ItemsTableViewCell.self, forCellReuseIdentifier: "prototype")
        
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = false 
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
        return self.store.myItems.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat{
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = ItemsTableViewCell(style: .default, reuseIdentifier: "prototype")
        var myItemCurrent: MyItem!
        if searchController.isActive && searchController.searchBar.text != "" {
            myItemCurrent = self.filteredItems[indexPath.row]
        } else {
            myItemCurrent = self.store.myItems[indexPath.row]
        }
        
        // set the title and subtitle
        cell.titleLabel.text = myItemCurrent.itemName
        cell.subTitleLabel.text = self.store.getCategoryLabelFromID(id: myItemCurrent.categoryID)
        
        // set the icon for the getAgain status
        switch myItemCurrent.getAgain.rawValue {
        case "yes" :
            cell.getThisAgainLabel.text = Constants.iconLibrary.faCheckCircle.rawValue
            cell.getThisAgainLabel.textColor = UIColor(named: UIColor.ColorName.statusGreen)
        case "no" :
            cell.getThisAgainLabel.text = Constants.iconLibrary.faTimesCircle.rawValue
            cell.getThisAgainLabel.textColor = UIColor(named: UIColor.ColorName.statusRed)
        default:
            cell.getThisAgainLabel.text = Constants.iconLibrary.faQuestionCircle.rawValue
            cell.getThisAgainLabel.textColor = UIColor(named: UIColor.ColorName.disabledText)
        }
        
        // set the image
        if myItemCurrent.imageURL.isEmpty {
            // show no image found
            cell.itemImageView.image = #imageLiteral(resourceName: "noImageFound.jpg")
        } else {
            // show the image per the URL
            let itemImageURL = URL(string: myItemCurrent.imageURL)
            cell.itemImageView.sd_setImage(with: itemImageURL)
        }
        cell.itemImageView.contentMode = .scaleAspectFit
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if searchController.isActive && searchController.searchBar.text != "" {
            self.delegate?.openItemDetail(item: self.filteredItems[indexPath.row])
        } else {
            self.delegate?.openItemDetail(item: self.store.myItems[indexPath.row])
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredItems = self.store.myItems.filter { myItem in
            var nameAndCategory = String()
            nameAndCategory = myItem.itemName + self.store.getCategoryLabelFromID(id: myItem.categoryID)
            return nameAndCategory.lowercased().contains(searchText.lowercased())
        }
        self.myItemsTableView.reloadData()
    }
    
    func pageLayout() {
        
        // myItemsTableView
        self.addSubview(self.myItemsTableView)
        self.myItemsTableView.translatesAutoresizingMaskIntoConstraints = false
        self.myItemsTableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 64).isActive = true
        self.myItemsTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -50).isActive = true
        self.myItemsTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.myItemsTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
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


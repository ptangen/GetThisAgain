//
//  MyItemsView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol MyItemsViewDelegate: class {
    func openItemDetail(item: MyItem, editMode: Bool)
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
        self.myItemsTableView.register(MyItemsTableViewCell.self, forCellReuseIdentifier: "prototype")
        
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
        let cell = MyItemsTableViewCell(style: .default, reuseIdentifier: "prototype")
        var myItemCurrent: MyItem!
        if searchController.isActive && searchController.searchBar.text != "" {
            myItemCurrent = self.filteredItems[indexPath.row]
        } else {
            myItemCurrent = self.store.myItems[indexPath.row]
        }
        
        cell.titleLabel.text = myItemCurrent.name  + " (" + myItemCurrent.getAgain.label() + ")"
        cell.subTitleLabel.text = myItemCurrent.category
        
        // var imageURLString = String()
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
            self.delegate?.openItemDetail(item: self.filteredItems[indexPath.row], editMode: true)
        } else {
            self.delegate?.openItemDetail(item: self.store.myItems[indexPath.row], editMode: true)
        }
    }
    
    func filterContentForSearchText(searchText: String, scope: String = "All") {
        self.filteredItems = self.store.myItems.filter { myItem in
            var nameAndCategory = String()
            nameAndCategory = myItem.name + myItem.category
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
        self.myItemsTableView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 0).isActive = true
        self.myItemsTableView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func getMyItemsFromDB() {
        APIClient.getMyItems(userName: "ptangen") { isSuccessful in
            if isSuccessful {
                OperationQueue.main.addOperation {
                    self.myItemsTableView.reloadData()
                }
            } else {
                OperationQueue.main.addOperation {
                    //self.activityIndicator.isHidden = true
                }
                self.delegate?.showAlertMessage("Unable to retrieve data from the server.")
            }
        }
        
        
        
        //        let myItem1 = Item(barcode: "0073852009385", name: "Purell H/Sanit Gel Aloe 2oz", category: "Bath / Beauty / Hygiene", imageURL: "http://eandata.com/image/products/007/385/200/0073852009385.jpg", shoppingList: false, getAgain: .yes)
        //        self.myItems.append(myItem1)
        //
        //        let myItem2 = Item(barcode: "0037600106245", name: "Skippy Peanut Butter Creamy, 28 oz", category: "Food", imageURL: "http://eandata.com/image/products/003/760/010/0037600106245.jpg", shoppingList: false, getAgain: .yes)
        //        self.myItems.append(myItem2)
        //
        //        let myItem3 = Item(barcode: "0072940748007", name: "Redpack Tomato Paste 6 Oz", category: "Food", imageURL: "http://eandata.com/image/products/007/294/074/0072940748007.jpg", shoppingList: true, getAgain: .yes)
        //        self.myItems.append(myItem3)
        //
        //        let myItem4 = Item(barcode: "0787780770193", name: "French Vanilla Decaffeinated, Ground, 10-Ounce Bags, New England", category: "Food", imageURL: "http://eandata.com/image/products/078/778/077/0787780770193.jpg", shoppingList: false, getAgain: .no)
        //        self.myItems.append(myItem4)
        //
        //        let myItem5 = Item(barcode: "0711381000083", name: "Stonewall Stonewall Wld Maine Blubr 13 Oz", category: "Food", imageURL: "http://eandata.com/image/products/071/138/100/0711381000083.jpg", shoppingList: true, getAgain: .yes)
        //        self.myItems.append(myItem5)
        
    }
}

extension MyItemsView: UISearchResultsUpdating {
    public func updateSearchResults(for searchController: UISearchController) {
        if let searchText = self.searchController.searchBar.text {
            self.filterContentForSearchText(searchText: searchText)
        }
    }
}


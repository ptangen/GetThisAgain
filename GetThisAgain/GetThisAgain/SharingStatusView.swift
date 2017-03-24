//
//  SharingStatusView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/23/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol SharingStatusViewDelegate: class {
    func onTapDeleteUser(message: String)
    func showAlertMessage(message: String)
}

class SharingStatusView: UIView, UITableViewDataSource, UITableViewDelegate  {

    weak var delegate: SharingStatusViewDelegate?
    let store = DataStore.sharedInstance
    //var filteredItems = [MyItem]()
    let usersWithAccessToMyListTableView = UITableView()
    let sectionTitles = ["People that see my shopping list", "People whose shopping lists I can see"]
    var deleteUserButton = UIButton()
    var selectedSection = String()
    var selectedUserName = String()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        self.usersWithAccessToMyListTableView.delegate = self
        self.usersWithAccessToMyListTableView.dataSource = self
        
        // deleteCategoryButton
        self.deleteUserButton.addTarget(self, action: #selector(self.onTapDeleteUser), for: UIControlEvents.touchUpInside)
        self.deleteUserButton.setTitle(Constants.iconLibrary.delete.rawValue, for: .normal)
        self.deleteUserButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.deleteUserButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.deleteUserButton.setTitleColor(UIColor(named: .disabledText), for: .disabled)
        self.deleteUserButton.isEnabled = false
        
        self.pageLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func onTapDeleteUser() {
        if let delegate = self.delegate {
            delegate.onTapDeleteUser(message: "Are you sure you want to remove '\(self.selectedUserName)' from '\(self.selectedSection)'?")
        }
    }
    
    // tableview config
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionTitles.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitles[section] + ":"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.store.sharedListStatus.isEmpty {
            return 0
        } else {
            return self.store.sharedListStatus[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: .default, reuseIdentifier: "prototype")
        
        if let textLabel = cell.textLabel {
            textLabel.text = self.store.sharedListStatus[indexPath.section][indexPath.row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.store.sharedListStatus[indexPath.section][indexPath.row] != "You cannot see anyone's list." && self.store.sharedListStatus[indexPath.section][indexPath.row] != "No one can see your list." {
            self.selectedSection = self.sectionTitles[indexPath.section]
            self.selectedUserName = self.store.sharedListStatus[indexPath.section][indexPath.row]
            self.deleteUserButton.isEnabled = true
        } else {
            self.deleteUserButton.isEnabled = false
        }
    }
    
    func pageLayout() {
        
        // myItemsTableView
        self.addSubview(self.usersWithAccessToMyListTableView)
        self.usersWithAccessToMyListTableView.translatesAutoresizingMaskIntoConstraints = false
        self.usersWithAccessToMyListTableView.topAnchor.constraint(equalTo: self.topAnchor, constant: 120).isActive = true
        self.usersWithAccessToMyListTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.usersWithAccessToMyListTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.usersWithAccessToMyListTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // delete user button
        self.addSubview(self.deleteUserButton)
        self.deleteUserButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteUserButton.bottomAnchor.constraint(equalTo: self.usersWithAccessToMyListTableView.topAnchor, constant: -4).isActive = true
        self.deleteUserButton.rightAnchor.constraint(equalTo: self.usersWithAccessToMyListTableView.rightAnchor, constant: -12).isActive = true
    }
    
    func getSharingStatusFromDB() {
        self.store.sharedListStatus.removeAll()
        
        APIClient.selectSharedLists(completion: { isSuccessful in
            if isSuccessful {
                OperationQueue.main.addOperation {
                    self.usersWithAccessToMyListTableView.reloadData()
                }
            } else {
                OperationQueue.main.addOperation {
                    //self.activityIndicator.isHidden = true  TODO: Add spinner
                }
                self.delegate?.showAlertMessage(message: "Unable to retrieve data from the server.")
            }
        })
    }
}

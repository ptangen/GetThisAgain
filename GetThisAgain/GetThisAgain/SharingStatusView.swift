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
    let usersWithAccessTableView = UITableView()
    let sectionTitles = ["People that can see my shopping list", "People whose shopping lists I can see"]
    var deleteUserButton = UIButton()
    var selectedSection = Int()
    var selectedUserName = String()
    var selectedListID = Int()
    var tabDescription = UILabel()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        self.tabDescription.text = "Review who you are sharing your shopping list with and who is sharing their shopping list with you."
        self.tabDescription.numberOfLines = 0
        
        self.usersWithAccessTableView.delegate = self
        self.usersWithAccessTableView.dataSource = self
        
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
            delegate.onTapDeleteUser(message: "Are you sure you want to remove '\(self.selectedUserName)' from '\(self.sectionTitles[self.selectedSection])'?")
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
            textLabel.text = self.store.sharedListStatus[indexPath.section][indexPath.row].userName
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.store.sharedListStatus[indexPath.section][indexPath.row].userName != "You cannot see anyone's list." && self.store.sharedListStatus[indexPath.section][indexPath.row].userName != "No one can see your list." {
            self.selectedSection = indexPath.section
            self.selectedUserName = self.store.sharedListStatus[indexPath.section][indexPath.row].userName
            selectedListID = self.store.sharedListStatus[indexPath.section][indexPath.row].listID
            
            self.deleteUserButton.isEnabled = true
        } else {
            self.deleteUserButton.isEnabled = false
        }
    }
    
    func pageLayout() {
        
        // tabDescription
        self.addSubview(self.tabDescription)
        self.tabDescription.translatesAutoresizingMaskIntoConstraints = false
        self.tabDescription.topAnchor.constraint(equalTo: self.topAnchor, constant: 72).isActive = true
        self.tabDescription.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 6).isActive = true
        self.tabDescription.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 6).isActive = true
        
        // myItemsTableView
        self.addSubview(self.usersWithAccessTableView)
        self.usersWithAccessTableView.translatesAutoresizingMaskIntoConstraints = false
        self.usersWithAccessTableView.topAnchor.constraint(equalTo: self.tabDescription.bottomAnchor, constant: 60).isActive = true
        self.usersWithAccessTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        self.usersWithAccessTableView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        self.usersWithAccessTableView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        // delete user button
        self.addSubview(self.deleteUserButton)
        self.deleteUserButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteUserButton.bottomAnchor.constraint(equalTo: self.usersWithAccessTableView.topAnchor, constant: -4).isActive = true
        self.deleteUserButton.rightAnchor.constraint(equalTo: self.usersWithAccessTableView.rightAnchor, constant: -12).isActive = true
    }
    
    func getSharingStatusFromDB() {
        
        APIClient.selectSharedLists(completion: { isSuccessful in
            if isSuccessful {
                OperationQueue.main.addOperation {
                    self.usersWithAccessTableView.reloadData()
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

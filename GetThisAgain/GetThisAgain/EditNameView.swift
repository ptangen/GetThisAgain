//
//  EditNameView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

protocol EditNameViewDelegate: class {
    func showAddCategory()
    func deleteCategoryClicked(id: Int)
}

class EditNameView: UIView, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: EditNameViewDelegate?
    let store = DataStore.sharedInstance
    var itemImageView = UIImageView()
    var nameLabel = UILabel()
    var nameTextView = UITextView()
    var nameTextViewDidChange = false
    var categoryTableView = UITableView()
    var categoryLabel = UILabel()
    var categoryTableViewTopBorder = UIView()
    var addCategoryButton = UIButton()
    var deleteCategoryButton = UIButton()
    var itemInst: MyItem?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.accessibilityLabel = "editNameViewInst"
        self.nameLabel.text = "Name"
        self.categoryLabel.text = "Category"
        self.nameTextView.delegate = self
        self.nameTextView.returnKeyType = .done
        self.nameTextView.accessibilityLabel = "nameTextView"
        self.layoutPage()
        
        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        self.categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "prototype")
        self.categoryTableView.accessibilityIdentifier = "categoryTableView"
        
        // select the first category by default
        let indexPath = IndexPath(item: 0, section: 0)
        self.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        
        // addCategoryButton
        self.addCategoryButton.addTarget(self, action: #selector(self.onTapAddCategory), for: UIControlEvents.touchUpInside)
        self.addCategoryButton.setTitle(Constants.iconLibrary.add.rawValue, for: .normal)
        self.addCategoryButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.addCategoryButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.addCategoryButton.accessibilityLabel = "addCategoryButton"
        
        // deleteCategoryButton
        self.deleteCategoryButton.addTarget(self, action: #selector(self.onTapDeleteCategory), for: UIControlEvents.touchUpInside)
        self.deleteCategoryButton.setTitle(Constants.iconLibrary.delete.rawValue, for: .normal)
        self.deleteCategoryButton.titleLabel!.font =  UIFont(name: Constants.iconFont.material.rawValue, size: CGFloat(Constants.iconSize.small.rawValue))
        self.deleteCategoryButton.setTitleColor(UIColor(named: .blue), for: .normal)
        self.deleteCategoryButton.setTitleColor(UIColor(named: .disabledText), for: .disabled)
        self.deleteCategoryButton.isEnabled = false
        self.deleteCategoryButton.accessibilityLabel = "deleteCategoryButton"
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // dismiss keyboard when user clicks return/done, the return button is changed to a done button during init
        if(text == "\n") {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // tableview
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.store.myCategories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "prototype")
        if let textLabel = cell.textLabel {
            textLabel.text = self.store.myCategories[indexPath.row].label
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let itemInst = self.itemInst {
            itemInst.categoryID = self.store.myCategories[indexPath.row].id
        }
        self.enableDisbleDeleteButton() // the selection has changed so we may be able to delete an item now
    }
    
    func getSelectedCategoryID() -> Int {
        if let indexPath = self.categoryTableView.indexPathForSelectedRow {
            return self.store.myCategories[indexPath.row].id
        }
        return 0
    }
    
    func onTapAddCategory() {
        if let delegate = self.delegate {
            delegate.showAddCategory()
        }
    }
    
    func onTapDeleteCategory() {
        let selectedCategoryID = getSelectedCategoryID()
        if let delegate = self.delegate {
            delegate.deleteCategoryClicked(id: selectedCategoryID)
        }
    }
    
    func enableDisbleDeleteButton() {
        // iterate through the categories and determine if any categories are not associated with an item
        for category in self.store.myCategories {
            let itemsUsingCategoryID = self.store.myItems.filter({ $0.categoryID == category.id })
            if itemsUsingCategoryID.isEmpty && category.id != 0 {
                // we have an unused category (ignore none (0)). enable the delete button
                self.deleteCategoryButton.isEnabled = true
                break
            } else {
                self.deleteCategoryButton.isEnabled = false
            }
        }
    }

    func layoutPage() {
        
        // itemImageView
        self.addSubview(self.itemImageView)
        self.itemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true
        self.itemImageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        self.itemImageView.rightAnchor.constraint(equalTo: self.centerXAnchor, constant: -4).isActive = true
        self.itemImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true

        // nameTextView
        self.addSubview(self.nameTextView)
        self.nameTextView.translatesAutoresizingMaskIntoConstraints = false
        self.nameTextView.topAnchor.constraint(equalTo: self.topAnchor, constant: 74).isActive = true
        self.nameTextView.leftAnchor.constraint(equalTo: self.centerXAnchor, constant: 2).isActive = true
        self.nameTextView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8).isActive = true
        self.nameTextView.heightAnchor.constraint(equalToConstant: 110).isActive = true
        
        self.nameTextView.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.nameTextView.layer.borderColor = UIColor(named: .blue).cgColor
        self.nameTextView.layer.borderWidth = 1.0
        
        // nameLabel
        self.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.bottomAnchor.constraint(equalTo: self.nameTextView.topAnchor, constant: -4).isActive = true
        self.nameLabel.leftAnchor.constraint(equalTo: self.nameTextView.leftAnchor, constant: 0).isActive = true
        
        // categoryTableView
        self.addSubview(self.categoryTableView)
        self.categoryTableView.translatesAutoresizingMaskIntoConstraints = false
        self.categoryTableView.topAnchor.constraint(equalTo: self.itemImageView.bottomAnchor, constant: 50).isActive = true
        self.categoryTableView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        self.categoryTableView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1.0).isActive = true
        self.categoryTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        // categoryLabel
        self.addSubview(self.categoryLabel)
        self.categoryLabel.translatesAutoresizingMaskIntoConstraints = false
        self.categoryLabel.bottomAnchor.constraint(equalTo: self.categoryTableView.topAnchor, constant: -6).isActive = true
        self.categoryLabel.leftAnchor.constraint(equalTo: self.categoryTableView.leftAnchor, constant: 8).isActive = true
        
        // delete category button
        self.addSubview(self.deleteCategoryButton)
        self.deleteCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        self.deleteCategoryButton.bottomAnchor.constraint(equalTo: self.categoryTableView.topAnchor, constant: -4).isActive = true
        self.deleteCategoryButton.rightAnchor.constraint(equalTo: self.categoryTableView.rightAnchor, constant: -12).isActive = true
        
        // add category button
        self.addSubview(self.addCategoryButton)
        self.addCategoryButton.translatesAutoresizingMaskIntoConstraints = false
        self.addCategoryButton.bottomAnchor.constraint(equalTo: self.categoryTableView.topAnchor, constant: -4).isActive = true
        self.addCategoryButton.rightAnchor.constraint(equalTo: self.deleteCategoryButton.leftAnchor, constant: -12).isActive = true
        
        // categoryTableViewTopBorder
        self.addSubview(self.categoryTableViewTopBorder)
        self.categoryTableViewTopBorder.translatesAutoresizingMaskIntoConstraints = false
        self.categoryTableViewTopBorder.bottomAnchor.constraint(equalTo: self.categoryTableView.topAnchor, constant: 0).isActive = true
        self.categoryTableViewTopBorder.leftAnchor.constraint(equalTo: self.categoryTableView.leftAnchor, constant: 0).isActive = true
        self.categoryTableViewTopBorder.rightAnchor.constraint(equalTo: self.categoryTableView.rightAnchor, constant: 0).isActive = true
        self.categoryTableViewTopBorder.heightAnchor.constraint(equalToConstant: 1.0).isActive = true
        self.categoryTableViewTopBorder.backgroundColor = UIColor(named: .blue)
    }
}

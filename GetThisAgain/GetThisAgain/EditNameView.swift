//
//  EditNameView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class EditNameView: UIView, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let store = DataStore.sharedInstance
    var itemImageView = UIImageView()
    var nameLabel = UILabel()
    var nameTextView = UITextView()
    var nameTextViewDidChange = false
    var categoryTableView = UITableView()
    var categoryLabel = UILabel()
    var categoryTableViewTopBorder = UIView()
    //var categorySelected = Int()
    var itemInst: MyItem?
    
    //var itemExistsInDatastore = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nameLabel.text = "Name"
        self.categoryLabel.text = "Category"
        self.nameTextView.delegate = self
        self.nameTextView.returnKeyType = .done
        self.layoutPage()
        
        self.categoryTableView.delegate = self
        self.categoryTableView.dataSource = self
        self.categoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "prototype")
        
        // select the first category by default
        let indexPath = IndexPath(item: 0, section: 0)
        self.categoryTableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
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
        self.itemInst?.categoryID = self.store.myCategories[indexPath.row].id
    }
    
    func getSelectedCategoryID() -> Int {
        if let indexPath = self.categoryTableView.indexPathForSelectedRow {
            return self.store.myCategories[indexPath.row].id
        }
        return 0
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
        self.nameTextView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.nameTextView.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.nameTextView.layer.borderColor = UIColor(named: .blue).cgColor
        self.nameTextView.layer.borderWidth = 1.0
        
        // nameLabel
        self.addSubview(self.nameLabel)
        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.bottomAnchor.constraint(equalTo: self.nameTextView.topAnchor, constant: -6).isActive = true
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

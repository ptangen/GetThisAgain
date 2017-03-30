//
//  ItemsTableViewCell.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

import UIKit

class ItemsTableViewCell: UITableViewCell {
    
    let itemImageView = UIImageView()
    var titleLabel = UILabel()
    var getThisAgainLabel = UILabel()
    var subTitleLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // set the fonts
        self.titleLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.medium.rawValue)
        self.subTitleLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.getThisAgainLabel.font = UIFont(name: Constants.iconFont.fontAwesome.rawValue, size: Constants.iconSize.xxsmall.rawValue)
        
        self.cellLayout()
    }
    
    func cellLayout() {
        
        //itemImageView
        contentView.addSubview(self.itemImageView)
        self.itemImageView.translatesAutoresizingMaskIntoConstraints = false
        self.itemImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 6).isActive = true
        self.itemImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 6).isActive = true
        self.itemImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -6).isActive = true
        self.itemImageView.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        //titleLabel
        contentView.addSubview(self.titleLabel)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -2).isActive = true
        self.titleLabel.leftAnchor.constraint(equalTo: self.itemImageView.rightAnchor, constant: 6).isActive = true
        self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        //getThisAgainLabel
        contentView.addSubview(self.getThisAgainLabel)
        self.getThisAgainLabel.translatesAutoresizingMaskIntoConstraints = false
        self.getThisAgainLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
        self.getThisAgainLabel.leftAnchor.constraint(equalTo: self.titleLabel.leftAnchor, constant: 0).isActive = true
        self.getThisAgainLabel.widthAnchor.constraint(equalToConstant: 12)
        
        //subTitleLabel
        contentView.addSubview(self.subTitleLabel)
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subTitleLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
        self.subTitleLabel.leftAnchor.constraint(equalTo: self.getThisAgainLabel.rightAnchor, constant: 12).isActive = true
    }

}

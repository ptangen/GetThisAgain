//
//  ItemsTableViewCell.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

class ItemsTableViewCell: UITableViewCell {
    
    let itemImageView = UIImageView()
    var titleLabel = UILabel()
    var getThisAgainAndMerchantLabel = UILabel()
    var subTitleLabel = UILabel()
    var userNameLabel = UILabel()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        // set the fonts
        self.titleLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.medium.rawValue)
        self.titleLabel.accessibilityIdentifier = "titleLabel"
        self.subTitleLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.subTitleLabel.accessibilityIdentifier = "subTitleLabel"
        self.userNameLabel.font = UIFont(name: Constants.appFont.regular.rawValue, size: Constants.fontSize.small.rawValue)
        self.userNameLabel.textAlignment = .right
        self.getThisAgainAndMerchantLabel.font = UIFont(name: Constants.iconFont.fontAwesome.rawValue, size: Constants.iconSize.xxsmall.rawValue)
        
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
        
        //getThisAgainAndMerchantLabel
        contentView.addSubview(self.getThisAgainAndMerchantLabel)
        self.getThisAgainAndMerchantLabel.translatesAutoresizingMaskIntoConstraints = false
        self.getThisAgainAndMerchantLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
        self.getThisAgainAndMerchantLabel.leftAnchor.constraint(equalTo: self.titleLabel.leftAnchor, constant: 0).isActive = true
        self.getThisAgainAndMerchantLabel.widthAnchor.constraint(equalToConstant: 12)
        
        //userNameLabel
        contentView.addSubview(self.userNameLabel)
        self.userNameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.userNameLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
        self.userNameLabel.rightAnchor.constraint(equalTo: self.titleLabel.rightAnchor, constant: -8).isActive = true
        
        //subTitleLabel
        contentView.addSubview(self.subTitleLabel)
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subTitleLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
        self.subTitleLabel.leftAnchor.constraint(equalTo: self.getThisAgainAndMerchantLabel.rightAnchor, constant: 12).isActive = true
        self.subTitleLabel.rightAnchor.constraint(equalTo: self.userNameLabel.leftAnchor, constant: -12).isActive = true
    }
}

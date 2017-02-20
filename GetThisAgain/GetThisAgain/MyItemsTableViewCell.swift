//
//  MyItemsTableViewCell.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit

import UIKit

class MyItemsTableViewCell: UITableViewCell {
    
    var titleLabel = UILabel()
    var subTitleLabel = UILabel()
    let itemImageView = UIImageView()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
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
        self.titleLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(16.0))
        
        self.titleLabel.bottomAnchor.constraint(equalTo: self.centerYAnchor, constant: -2).isActive = true
        self.titleLabel.leftAnchor.constraint(equalTo: self.itemImageView.rightAnchor, constant: 6).isActive = true
        self.titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 0).isActive = true
        
        //subTitleLabel
        contentView.addSubview(self.subTitleLabel)
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subTitleLabel.font = UIFont(name: "HelveticaNeue", size: CGFloat(11.0))
        
        self.subTitleLabel.topAnchor.constraint(equalTo: self.centerYAnchor, constant: 2).isActive = true
        self.subTitleLabel.leftAnchor.constraint(equalTo: self.titleLabel.leftAnchor, constant: 0).isActive = true
        self.subTitleLabel.rightAnchor.constraint(equalTo: self.titleLabel.rightAnchor, constant: 0).isActive = true
    }
}

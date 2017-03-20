//
//  MyList.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class MyList {
    
    var id: Int
    var createdBy: String
    var label: String
    var owner: Bool
    
    init (id: Int, createdBy: String, label: String, owner: Bool ) {
        self.id = id
        self.createdBy = createdBy
        self.label = label
        self.owner = owner
    }
}

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
    var owner: String
    var label: String
    
    init (id: Int, owner: String, label: String) {
        self.id = id
        self.owner = owner
        self.label = label
    }
}

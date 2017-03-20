//
//  MyCategory.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/14/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class MyCategory {
    
    var createdBy: String
    var id: Int
    var label: String
    
    init (createdBy: String, id: Int, label: String) {
        self.createdBy = createdBy
        self.id = id
        self.label = label
    }
}

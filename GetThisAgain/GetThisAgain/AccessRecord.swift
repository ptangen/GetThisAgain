//
//  AccessRecord.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/27/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

class AccessRecord {
    
    var id: Int
    var owner: String
    var viewer: String
    var status: String
    
    init (id: Int, owner: String, viewer: String, status: String) {
        self.id = id
        self.owner = owner
        self.viewer = viewer
        self.status = status
    }
}

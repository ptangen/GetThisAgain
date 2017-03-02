//
//  CameraView.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/1/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import UIKit



class CameraView: UIView {
    
    var itemInst: Item!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layoutPage()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func layoutPage() {
        self.backgroundColor = UIColor.brown
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

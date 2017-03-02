//
//  Utilities.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 3/2/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation

import UIKit

class Utilities {
    
    class func showAlertMessage(_ message: String, viewControllerInst: UIViewController) {
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default,handler: nil))
        viewControllerInst.present(alertController, animated: true, completion: nil)
    }
    

}

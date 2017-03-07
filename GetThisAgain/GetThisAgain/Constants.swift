//
//  Constants.swift
//  GetThisAgain
//
//  Created by Paul Tangen on 2/17/17.
//  Copyright © 2017 Paul Tangen. All rights reserved.
//

import Foundation
import UIKit

struct Constants{
    
    enum fontSize: CGFloat {
        case xxsmall =      12
        case xsmall =       14
        case small =        16
        case medium =       18
        case large =        24
        case xlarge =       36
        case xxlarge =      48
    }
    
//    enum iconLibrary: String {
//        case menu =             "\u{E5D2}"
//        case faCheckCircle =    "\u{f058}"
//        case faTimesCircle =    "\u{f057}"
//        case faCircleO =        "\u{f10c}"
//        case faInfoCircle =     "\u{f05a}"
//    }
//    
//    enum iconSize: CGFloat {
//        case xsmall = 20
//        case small = 24
//        case medium = 36
//        case large = 72
//    }
//    
//    enum iconFont: String {
//        case material = "MaterialIcons-Regular"
//        case fontAwesome = "FontAwesome"
//    }
    
    enum appFont: String {
        case regular =  "HelveticaNeue"
        case bold =     "HelveticaNeue-Bold"
    }
    
    enum barcodeType: String {
        case EAN13, UPCA
    }
    
    enum ItemCategory: String {
        case none =         "none"
        case automotive =   "Automotive"
        case bath =         "Bath / Beauty / Hygiene"
        case beverages =    "Beverages"
        case book =         "Book / Magazine / Publication"
        case cleaning =     "Cleaning Supplies / Equipment"
        case electronics =  "Electronics / Photography"
        case food =         "Food"
        case garden =       "Garden"
        case hardware =     "Hardware"
        case linnen =       "Linnen / Bath"
        case movie =        "Movie"
        case office =       "Office / School Supplies"
        case sports =       "Sports / Exercise"
        case wine =         "Wine / Champagne"
        
        static let allValues = [none, automotive, bath, beverages, book, cleaning, electronics, food, garden, hardware, linnen, movie, office, sports, wine]
        

    }
    
    static func getItemCategoryFromString(categoryString: String) -> ItemCategory {
        switch categoryString {
        case "automotive": return Constants.ItemCategory.automotive
        case "bath": return Constants.ItemCategory.bath
        case "beverages": return Constants.ItemCategory.beverages
        case "book": return Constants.ItemCategory.book
        case "cleaning": return Constants.ItemCategory.cleaning
        case "electronics": return Constants.ItemCategory.electronics
        case "food": return Constants.ItemCategory.food
        case "garden": return Constants.ItemCategory.garden
        case "hardware": return Constants.ItemCategory.hardware
        case "linnen": return Constants.ItemCategory.linnen
        case "movie": return Constants.ItemCategory.movie
        case "office": return Constants.ItemCategory.office
        case "sports": return Constants.ItemCategory.sports
        case "wine": return Constants.ItemCategory.wine
        default: return Constants.ItemCategory.none
        }
    }
}

extension UIColor {
    enum ColorName : UInt32 {
        case blue =             0x0096EAff
        case statusBarBlue =    0x0076B7ff
        case disabledText =     0xCCCCCCff
        case brown =            0x7b4e21ff
        case statusGreen =      0x3DB66Fff
        case statusRed =        0xdf1a21ff
        case beige =            0xF5F5DCff
    }
}

extension UIColor {
    convenience init(named name: ColorName) {
        let rgbaValue = name.rawValue
        let red   = CGFloat((rgbaValue >> 24) & 0xff) / 255.0
        let green = CGFloat((rgbaValue >> 16) & 0xff) / 255.0
        let blue  = CGFloat((rgbaValue >>  8) & 0xff) / 255.0
        let alpha = CGFloat((rgbaValue      ) & 0xff) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}

//
//  CommonExtensions.swift
//  Pods-Sample
//
//  Created by Meniny on 2018-01-21.
//

import Foundation
import UIKit

public enum SuperAlertControllerPickerIcon: String {
    case calendar = "calendar"
    case clip = "clip"
    case colors = "colors"
    case currency = "currency"
    case four_rect = "four_rect"
    case globe = "globe"
    case library = "library"
    case listings = "listings"
    case login = "login"
    case padlock = "padlock"
    case pen = "pen"
    case picker = "picker"
    case planet = "planet"
    case rect = "rect"
    case telephone = "telephone"
    case title = "title"
    case two_squares = "two_squares"
    case user = "user"
    
    public var image: UIImage {
        return UIImage.init(named: self.rawValue, in: Bundle.SACPBundle, compatibleWith: nil)!
    }
}

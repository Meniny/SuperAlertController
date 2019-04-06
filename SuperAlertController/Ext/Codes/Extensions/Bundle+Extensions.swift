//
//  Bundle+Extensions.swift
//  Pods-Sample
//
//  Created by Meniny on 2018-01-21.
//

import Foundation

private class BundleClass {
    
}

public extension Bundle {
    class var SACPBundle: Bundle {
        return Bundle.init(for: BundleClass.self)
    }
    
    class var countriesBundle: Bundle {
        return Bundle.init(path: "Countries.bundle")!
    }
}

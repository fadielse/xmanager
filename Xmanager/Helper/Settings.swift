//
//  Settings.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 26/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

class Settings {
    
    enum Keys: String {
        case isSampleHasGenerated = "isSampleHasGenerated"
    }
    
    static var isSampleHasGenerated: Bool {
        get {
            return UserDefaults.standard.bool(forKey: Keys.isSampleHasGenerated.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Keys.isSampleHasGenerated.rawValue)
            UserDefaults.standard.synchronize()
        }
    }
}

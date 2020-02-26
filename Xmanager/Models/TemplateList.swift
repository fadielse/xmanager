//
//  TemplateList.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct TemplateList {
    
    var name: String?
    var list: [String] = []
    
    init(withData data: [String: Any]) {
        self.name = data["name"] as? String
    }
}

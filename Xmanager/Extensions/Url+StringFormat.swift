//
//  Url+StringFormat.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

extension URL {
    
    func getName() -> String {
        return String(absoluteString.split(separator: "/").last?.removingPercentEncoding ?? "").replacingOccurrences(of: ".xctemplate", with: "")
    }
}

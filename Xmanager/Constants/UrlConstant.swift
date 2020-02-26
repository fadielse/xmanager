//
//  UrlConstant.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct UrlConstant {
    
    static let basePath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent(".XcodeTemplateManager")
    static let xcodeTemplatePath = URL(fileURLWithPath: NSHomeDirectory()).appendingPathComponent("Library/Developer/Xcode/Templates/Xmanager")
}

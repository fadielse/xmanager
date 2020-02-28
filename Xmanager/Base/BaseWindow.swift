//
//  BaseWindow.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 17/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class BaseWindow: NSWindow {
    
    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: style, backing: backingStoreType, defer: flag)
    
        backgroundColor = ColorConstant.semiDarkBackground
        toolbar?.sizeMode = .regular
    }
}

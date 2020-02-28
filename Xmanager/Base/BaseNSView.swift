//
//  BaseNSView.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 17/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class BaseNSView: NSView {

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        layer?.cornerRadius = 5.0
        ColorConstant.darkBlue.setFill()
        dirtyRect.fill()
    }
    
}

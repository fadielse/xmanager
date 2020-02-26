//
//  DragAndDropView.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 20/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

class DragAndDropView: BaseNSView {
    
    override func draw(_ dirtyRect: NSRect) {
        
        ColorConstant.mouseHoverBackground.setFill()
        dirtyRect.fill()
    }
}

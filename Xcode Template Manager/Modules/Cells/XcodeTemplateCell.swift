//
//  XcodeTemplateCell.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 13/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class XcodeTemplateCell: NSTableCellView {

    @IBOutlet weak var labelName: NSTextField!
    @IBOutlet weak var stackViewTemplateData: NSStackView!
    
    var dataView: [NSView] = []
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }
    
    func showData() {
        for _ in 1...10 {
            let view = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 40))
            view.layer?.backgroundColor = .white
            dataView.append(view)
        }
        
        for view in dataView {
            stackViewTemplateData.addView(view, in: .leading)
        }
    }
    
    func removeData() {
        for view in dataView {
            stackViewTemplateData.removeView(view)
        }
    }
}

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
    
    var data: [String] = []
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
    }
    
    func showData() {
        if stackViewTemplateData.subviews.count > 0 {
            for view in stackViewTemplateData.subviews {
                view.isHidden = false
            }
        } else {
            for _ in data {
                let view = NSView(frame: NSRect(x: 0, y: 0, width: self.frame.width, height: 40))
                view.layer?.backgroundColor = .white
                stackViewTemplateData.addArrangedSubview(view)
            }
        }
        
        print(labelName.stringValue)
        print("number of data \(data.count)")
        print("number of view \(stackViewTemplateData.subviews.count)")
    }
    
    func removeData() {
        for view in stackViewTemplateData.subviews {
            view.isHidden = true
        }
    }
}

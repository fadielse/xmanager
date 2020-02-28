//
//  SourceFileTableCell.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 19/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

protocol SourceFileTableCellDelegate {
    func SourceFileTableCell(updateFileName name: String, withUrl url: URL)
}

class SourceFileTableCell: NSTableRowView {

    @IBOutlet weak var labelName: NSTextField!
    
    var delegate: SourceFileTableCellDelegate?
    
    var oldName = ""
    var newName = ""
    var fileUrl: URL?
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        labelName.delegate = self
    }
    
    func startEditing(withFileUrl fileUrl: URL) {
        self.fileUrl = fileUrl
        oldName = labelName.stringValue
        newName = labelName.stringValue
        labelName.isEditable = true
        labelName.isEnabled = true
        labelName.becomeFirstResponder()
    }
    
    func stopEditing() {
        labelName.isEditable = false
        labelName.isEnabled = false
        labelName.resignFirstResponder()
        
        if oldName != newName, let fileUrl = fileUrl {
            self.delegate?.SourceFileTableCell(updateFileName: newName, withUrl: fileUrl)
        }
    }
}

extension SourceFileTableCell: NSTextFieldDelegate {
    
    func controlTextDidEndEditing(_ obj: Notification) {
        stopEditing()
    }
    
    func controlTextDidChange(_ obj: Notification) {
        newName = labelName.stringValue
    }
}

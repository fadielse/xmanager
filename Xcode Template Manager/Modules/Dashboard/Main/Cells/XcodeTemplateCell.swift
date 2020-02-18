//
//  XcodeTemplateCell.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 13/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

protocol XcodeTemplateCellDelegate {
    func XcodeTemplateCell(didUpdateNameWithCell cell: XcodeTemplateCell)
    func XcodeTemplateCell(deleteGroupWithCell cell: XcodeTemplateCell)
}

class XcodeTemplateCell: NSTableRowView {

    @IBOutlet weak var labelName: NSTextField!
    @IBOutlet weak var viewEdit: NSView!
    @IBOutlet weak var viewDelete: NSView!
    
    var delegate: XcodeTemplateCellDelegate?
    var data: [String] = []
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        if isSelected {
            let selectionRect = NSInsetRect(self.bounds, 0, 0)
            ColorConstant.darkBlue.setFill()
            let selectionPath = NSBezierPath.init(rect: selectionRect)
            selectionPath.fill()
        } else {
            let selectionRect = NSInsetRect(self.bounds, 0, 0)
            ColorConstant.darkBackground.setFill()
            let selectionPath = NSBezierPath.init(rect: selectionRect)
            selectionPath.fill()
        }
        
        viewEdit.isHidden = !isSelected
        viewDelete.isHidden = !isSelected
    }
    
    @IBAction func onEditButtonClicked(_ sender: Any) {
        labelName.isEditable = true
        labelName.becomeFirstResponder()
        labelName.delegate = self
    }
    
    @IBAction func onDeleteButtonClicked(_ sender: Any) {
        delegate?.XcodeTemplateCell(deleteGroupWithCell: self)
    }
}

extension XcodeTemplateCell: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            guard !labelName.stringValue.isEmpty else {
                labelName.resignFirstResponder()
                labelName.isEditable = false
                return false
            }
            labelName.resignFirstResponder()
            labelName.isEditable = false
            delegate?.XcodeTemplateCell(didUpdateNameWithCell: self)
            return true
        }
        
        return false
    }
}

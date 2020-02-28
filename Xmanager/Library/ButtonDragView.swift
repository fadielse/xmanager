//
//  ButtonDragView.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 19/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

protocol ButtonDragViewDelegate {
    func buttonDragView(didDragFileWithUrls urls: [URL])
}

class ButtonDragView: NSButton {
    
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    var delegate: ButtonDragViewDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Declare and register an array of accepted types
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeItem as String)])
    }

    let fileTypes = ["png"]
    var fileTypeIsOk = false
    var droppedFilePath: [URL] = []

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        if checkExtension(drag: sender) {
            fileTypeIsOk = true
            return .copy
        } else {
            fileTypeIsOk = false
            return []
        }
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        if fileTypeIsOk {
            return .copy
        } else {
            return []
        }
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray, let imagePath = board as? [String] {
            // THIS IS WERE YOU GET THE PATH FOR THE DROPPED FILE
            droppedFilePath = imagePath.map(NSURL.init) as [URL]
            self.delegate?.buttonDragView(didDragFileWithUrls: droppedFilePath)
            return true
        }
        return false
    }

    func checkExtension(drag: NSDraggingInfo) -> Bool {
        if let board = drag.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray, let path = board[0] as? String {
            let url = NSURL(fileURLWithPath: path)
            if let fileExtension = url.pathExtension?.lowercased() {
                return fileTypes.contains(fileExtension)
            }
        }
        return false
    }
}

//
//  TableDragView.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 19/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

protocol TableDragViewDelegate {
    func tableDragView(didDragFileWithUrls urls: [URL])
}

class TableDragView: NSTableView {
    
    let NSFilenamesPboardType = NSPasteboard.PasteboardType("NSFilenamesPboardType")
    var dragDelegate: TableDragViewDelegate?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        // Declare and register an array of accepted types
        registerForDraggedTypes([NSPasteboard.PasteboardType(kUTTypeFileURL as String),
                                 NSPasteboard.PasteboardType(kUTTypeItem as String)])
    }

    var droppedFilePath: [URL] = []

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        return .copy
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        if let board = sender.draggingPasteboard.propertyList(forType: NSFilenamesPboardType) as? NSArray, let imagePath = board as? [String] {
            // THIS IS WERE YOU GET THE PATH FOR THE DROPPED FILE
            droppedFilePath = imagePath.map(NSURL.init) as [URL]
            self.dragDelegate?.tableDragView(didDragFileWithUrls: droppedFilePath)
            return true
        }
        return false
    }
}

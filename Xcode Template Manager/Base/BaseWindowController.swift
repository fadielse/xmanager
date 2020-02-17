//
//  BaseWindowController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 18/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class BaseWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.delegate = self
    }

    private func windowDidResize(notification: NSNotification) {
        print("asdasdasd")
    }
}

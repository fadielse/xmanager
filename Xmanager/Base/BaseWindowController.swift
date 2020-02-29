//
//  BaseWindowController.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 18/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa
import NotificationCenter

class BaseWindowController: NSWindowController, NSWindowDelegate {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        window?.delegate = self
    }
    
    func windowDidEndLiveResize(_ notification: Notification) {
        NotificationCenter.default.post(name: NotificationCenterConstant.reloadContainerView, object: nil)
    }
    
    func windowShouldClose(_ sender: NSWindow) -> Bool {
        NSApplication.shared.hide(self)
        return false
    }
}

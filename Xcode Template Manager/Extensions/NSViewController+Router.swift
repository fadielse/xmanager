//
//  NSViewController+Router.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 14/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

extension NSViewController {
    
    @discardableResult
    func goToScreen(withStoryboardId storyboardId: String, andViewControllerId viewControllerId: String) -> NSViewController {
        let storyBoard: NSStoryboard = NSStoryboard(name: storyboardId, bundle: nil)
        let newViewController = storyBoard.instantiateController(withIdentifier: viewControllerId)
        self.presentAsModalWindow(newViewController as! NSViewController)
        return newViewController as! NSViewController
    }
}

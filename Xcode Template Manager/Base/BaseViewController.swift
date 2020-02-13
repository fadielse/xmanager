//
//  BaseViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 13/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class BaseViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setWindowSize()
    }
    
    func setWindowSize() {
        preferredContentSize = NSSize(width: 1280, height: 800)
    }
    
    func setFullScreen() {
        let presOptions: NSApplication.PresentationOptions = ([.fullScreen,.autoHideMenuBar])
         /*These are all of the options for NSApplicationPresentationOptions
                     .Default
                     .AutoHideDock              |   /
                     .AutoHideMenuBar           |   /
                     .DisableForceQuit          |   /
                     .DisableMenuBarTransparency|   /
                     .FullScreen                |   /
                     .HideDock                  |   /
                     .HideMenuBar               |   /
                     .DisableAppleMenu          |   /
                     .DisableProcessSwitching   |   /
                     .DisableSessionTermination |   /
                     .DisableHideApplication    |   /
                     .AutoHideToolbar
                     .HideMenuBar               |   /
                     .DisableAppleMenu          |   /
                     .DisableProcessSwitching   |   /
                     .DisableSessionTermination |   /
                     .DisableHideApplication    |   /
                     .AutoHideToolbar */
                
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions :
             NSNumber(value: presOptions.rawValue)]
        
        self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
    }
}

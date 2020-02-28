//
//  BaseViewController.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 13/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class BaseViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
                
        let optionsDictionary = [NSView.FullScreenModeOptionKey.fullScreenModeApplicationPresentationOptions : NSNumber(value: presOptions.rawValue)]
        self.view.enterFullScreenMode(NSScreen.main!, withOptions:optionsDictionary)
        self.view.wantsLayer = true
    }
    
    internal func showAlert(withMessage message: String) {
        let alert = NSAlert()
        alert.messageText = ""
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
    }
    
    @discardableResult
    internal func showAlertConfirm(withTitle title: String, andMessage message: String, andActionButtonTitle actionButtonTitle: String? = "Delete") -> NSAlert {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.addButton(withTitle: actionButtonTitle ?? "Delete")
        alert.addButton(withTitle: "Cancel")
        alert.alertStyle = NSAlert.Style.warning
        
        return alert
    }
    
    internal func contentsOf(folder: URL) -> [URL] {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: folder.path)
            let urls = contents
                .filter { return $0.first != "." }
                .map { return folder.appendingPathComponent($0) }
            return urls
        } catch {
            return []
        }
    }
}

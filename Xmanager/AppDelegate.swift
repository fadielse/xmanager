//
//  AppDelegate.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 11/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa
import Zip

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    var baseWindowController: BaseWindowController?
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        baseWindowController = (NSApplication.shared.mainWindow?.windowController as? BaseWindowController)
        createBaseFolderIfNotExists()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        NSApplication.shared.unhide(self)
    }
    
    func applicationDockMenu(_ sender: NSApplication) -> NSMenu? {
        let dockMenu = NSMenu(title: "MyMenu")
        dockMenu.addItem(NSMenuItem(title: "Open", action: #selector(openMenuDockCLicked), keyEquivalent: "Cmd+1"))
        return dockMenu
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        baseWindowController = nil
        return false
    }
    
    @IBAction func onWindowOpenMenuCLicked(_ sender: Any) {
        openMenuDockCLicked()
    }
    
    @objc func openMenuDockCLicked() {
        if baseWindowController == nil {
            let storyBoard: NSStoryboard = NSStoryboard(name: "Dashboard", bundle: nil)
            baseWindowController = storyBoard.instantiateController(withIdentifier: "BaseWindowController") as? BaseWindowController
            baseWindowController?.window?.makeKeyAndOrderFront(self)
        }
    }
    
    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        openMenuDockCLicked()
        return true
    }
    

    func createBaseFolderIfNotExists() {
        do {
            try FileManager.default.createDirectory(at: UrlConstant.basePath, withIntermediateDirectories: true, attributes: nil)
            try FileManager.default.createDirectory(at: UrlConstant.xcodeTemplatePath, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print(error.localizedDescription)
        }
    }
}


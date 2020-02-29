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



    func applicationDidFinishLaunching(_ aNotification: Notification) {
        createBaseFolderIfNotExists()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {
        NSApplication.shared.unhide(self)
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


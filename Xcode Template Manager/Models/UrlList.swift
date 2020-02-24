//
//  UrlList.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct UrlList {
    
    var url: URL?
    
    init(url: URL) {
        self.url = url
    }
    
    func isTemplateImage1() -> Bool {
        guard let url = url else { return false }
        return url.absoluteString.contains("TemplateIcon.png")
    }
    
    func isTemplateImage2() -> Bool {
        guard let url = url else { return false }
        return url.absoluteString.contains("TemplateIcon@2x.png")
    }
    
    func isTemplateConfiguration() -> Bool {
        guard let url = url else { return false }
        return url.absoluteString.contains("TemplateInfo.plist")
    }
    
    func hasTemplateCode() -> Bool {
        return url?.absoluteString.contains("___FILEBASENAME___") ?? false
    }
    
    func getGenerateFilePlistFormat(withIndex index: Int, andIdentifier identifier: String) -> String {
        var text = ""
        text.append("<dict>")
        text.append("<key>Default</key>")
        text.append("<string>___VARIABLE_\(identifier):identifier___</string>")
        text.append("<key>Description</key>")
        text.append("<string>Generate File \(index)</string>")
        text.append("<key>Identifier</key>")
        text.append("<string>GeneratedFile\(index)</string>")
        text.append("<key>Name</key>")
        text.append("<string>Generate File \(index)</string>")
        text.append("<key>Required</key>")
        text.append("<true/>")
        text.append("<key>Type</key>")
        text.append("<string>static</string>")
        text.append("</dict>")
        return text
    }
}

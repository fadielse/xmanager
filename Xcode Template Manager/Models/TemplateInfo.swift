//
//  TemplateInfo.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 23/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct TemplateInfoOptionRows {
    
    static let properties = 0
    static let generateFile1 = 1
    static let generateFile2 = 2
    static let generateFile3 = 3
    static let generateFile4 = 4
    static let generateFile5 = 5
}

struct TemplateInfo {
    
    var kind: String?
    var platforms: [Platform] = []
    var options: [Options] = []
    
    init?(withDictionary dict: NSDictionary?) {
        guard let dict = dict else {
            return nil
        }
        
        self.kind = dict["Kind"] as? String
        for platform in dict["Platforms"] as? [String] ?? [] {
            self.platforms.append(Platform(withId: platform))
        }
        for option in dict["Options"] as? [NSDictionary] ?? [] {
            self.options.append(Options(withDictionary: option))
        }
    }
    
    struct Platform {
        
        var id: String?
        
        init(withId id: String) {
            self.id = id
        }
    }
    
    struct Options {
        
        var defaultString: String?
        var description: String?
        var identifier: String?
        var name: String?
        var notPersisted: Int?
        var required: Int = 0
        var type: String?
        
        init(withDictionary dict: NSDictionary) {
            self.defaultString = dict["Default"] as? String
            self.description = dict["Description"] as? String
            self.identifier = dict["Identifier"] as? String
            self.name = dict["Name"] as? String
            self.notPersisted = dict["NotPersisted"] as? Int
            self.required = dict["Required"] as? Int ?? 0
            self.type = dict["Type"] as? String
        }
        
        func getDefaultValue() -> String {
            return defaultString ?? ""
        }
    }
    
    func getPropertyIdentifier() -> String {
        guard options.indices.contains(TemplateInfoOptionRows.properties) else { return "" }
        let property = options[TemplateInfoOptionRows.properties]
        return property.identifier ?? ""
    }
    
    func getPropertyTitle() -> String {
        guard options.indices.contains(TemplateInfoOptionRows.properties) else { return "" }
        let property = options[TemplateInfoOptionRows.properties]
        return property.name?.replacingOccurrences(of: ":", with: "") ?? ""
    }
    
    func getPropertyDescription() -> String {
        guard options.indices.contains(0) else { return "" }
        let property = options[TemplateInfoOptionRows.properties]
        return property.description ?? ""
    }
    
    func isGenerateFileHidden(withIndex index: Int) -> Bool {
        guard options.indices.contains(index) else { return true }
        return false
    }
    
    func getMainPlistFormat(withName name: String, andDescription description: String) -> String {
        var text = ""
        text.append("<?xml version=\"1.0\" encoding=\"UTF-8\"?>")
        text.append("<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">")
        text.append("<plist version=\"1.0\">")
        text.append("<dict>")
        text.append("<key>Kind</key>")
        text.append("<string>Xcode.IDEKit.TextSubstitutionFileTemplateKind</string>")
        text.append("<key>Platforms</key>")
        text.append("<array>")
        text.append("<string>com.apple.platform.iphoneos</string>")
        text.append("</array>")
        text.append("<key>Options</key>")
        text.append("<array>")
        text.append("<dict>")
        text.append("<key>Description</key>")
        text.append("<string>\(description)</string>")
        text.append("<key>Identifier</key>")
        text.append("<string>\(name.removeWhiteSpace())</string>")
        text.append("<key>Name</key>")
        text.append("<string>\(name):</string>")
        text.append("<key>NotPersisted</key>")
        text.append("<true/>")
        text.append("<key>Required</key>")
        text.append("<true/>")
        text.append("<key>Type</key>")
        text.append("<string>text</string>")
        text.append("</dict>")
        return text
    }
    
    func getClosurePlistFormat() -> String {
        var text = ""
        text.append("</array>")
        text.append("</dict>")
        text.append("</plist>")
        return text
    }
}

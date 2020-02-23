//
//  TemplateInfo.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 23/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

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
        
        var description: String?
        var identifier: String?
        var name: String?
        var notPersisted: Int?
        var required: Int = 0
        var type: String?
        
        init(withDictionary dict: NSDictionary) {
            self.description = dict["Description"] as? String
            self.identifier = dict["Identifier"] as? String
            self.name = dict["Name"] as? String
            self.notPersisted = dict["NotPersisted"] as? Int
            self.required = dict["Required"] as? Int ?? 0
            self.type = dict["Type"] as? String
        }
    }
}

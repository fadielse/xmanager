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
}

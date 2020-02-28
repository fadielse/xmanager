//
//  UrlListDAO.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct UrlListDAO {
    
    var urlList: [UrlList] = []
     
    init(urls: [URL]) {
        for url in urls {
            self.urlList.append(UrlList(url: url))
        }
    }
    
    func isEmptyList() -> Bool {
        return urlList.count <= 0
    }
}

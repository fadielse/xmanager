//
//  TemplateListDAO.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct TemplateListDAO {
    
    var templateList: [TemplateList] = []
    
    init(data: [[String: Any]]) {
        for item in data {
            self.templateList.append(TemplateList(withData: item))
        }
    }
}

//
//  String+Format.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 25/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

extension String {
    
    func removeWhiteSpace() -> String {
        return replacingOccurrences(of: " ", with: "")
    }
    
    func between(_ left: String, _ right: String) -> String? {
        guard let leftRange = range(of: left), let rightRange = range(of: right, options: .backwards)
            ,leftRange.upperBound <= rightRange.lowerBound else { return nil }

        let sub = self[leftRange.upperBound...]
        let closestToLeftRange = sub.range(of: right)!
        return String(sub[..<closestToLeftRange.lowerBound])
    }
}

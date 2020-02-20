//
//  TextParser.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 20/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Foundation

struct TextParser {
    
    static func read(withFileName fileName: String) -> String? {
        if let filepath = Bundle.main.path(forResource: fileName, ofType: "txt") {
            do {
                let contents = try String(contentsOfFile: filepath)
                return contents
            } catch let error {
                print(error.localizedDescription)
                return nil
            }
        }
        return nil
    }
    
    static func write(withName name: String, andText text: String, toPathUrl pathUrl: URL) -> Bool {
        let fileURL = pathUrl.appendingPathComponent(name)

        do {
            try text.write(to: fileURL, atomically: false, encoding: .utf8)
            return true
        } catch let error {
            print(error.localizedDescription)
            return false
        }
    }
}

//
//  SyntaxTextStorage.swift
//  SyntaxHighlighting
//
//  Created by Sam Soffes on 2/8/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

import Cocoa

class SyntaxTextStorage: BaseTextStorage {
	override func processEditing() {
		let text = string as NSString

		setAttributes([
            NSAttributedString.Key.font: NSFont.systemFont(ofSize: 18)
		], range: NSRange(location: 0, length: length))

        text.enumerateSubstrings(in: NSRange(location: 0, length: length), options: .byWords) { [weak self] string, range, _, _ in
			guard let string = string else { return }
			if string.lowercased() == "red" {
                self?.addAttribute(NSAttributedString.Key.foregroundColor, value: NSColor.red, range: range)
			} else if string.lowercased() == "bold" {
                self?.addAttribute(NSAttributedString.Key.font, value: NSFont.boldSystemFont(ofSize: 18), range: range)
			}
		}

		super.processEditing()
	}
}

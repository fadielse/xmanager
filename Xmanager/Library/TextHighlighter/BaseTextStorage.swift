//
//  BaseTextStorage.swift
//  SyntaxHighlighting
//
//  Created by Sam Soffes on 2/8/16.
//  Copyright © 2016 Sam Soffes. All rights reserved.
//

import Cocoa

class BaseTextStorage: NSTextStorage {

	// MARK: - Properties

	private let storage = NSMutableAttributedString()


	// MARK: - NSTextStorage

	override var string: String {
		return storage.string
	}
    
    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return storage.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with string: String) {
		let beforeLength = length
        storage.replaceCharacters(in: range, with: string)
        edited(.editedCharacters, range: range, changeInLength: length - beforeLength)

	}

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        storage.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
    }
}

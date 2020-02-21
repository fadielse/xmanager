//
//  Editorswift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 21/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

enum EditorThemeStyle: String {
    case dark = "dracula"
    case light = "xcode"
}

class EditorTextView: NSTextView {
    
    var currentThemeStyle: EditorThemeStyle = .dark
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func layout() {
        let textStorage = CodeAttributedString()
        textStorage.language = "Swift"
        textStorage.highlightr.setTheme(to: currentThemeStyle.rawValue)
        textStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
        textStorage.addLayoutManager(layoutManager!)
        
        autoresizingMask = .width
        backgroundColor = NSColor.textBackgroundColor
        delegate = self.delegate
        drawsBackground = true
        font = self.font
        isEditable = self.isEditable
        isHorizontallyResizable = false
        isVerticallyResizable = true
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        minSize = NSSize(width: 0, height: 9000)
        textColor = NSColor.labelColor
    }
    
    override func didChangeText() {
        print("didChangeText")
        print(bounds)
    }
    
    var contentSize: CGSize {
        get {
            guard let layoutManager = layoutManager, let textContainer = textContainer else {
                print("textView no layoutManager or textContainer")
                return .zero
            }

            layoutManager.ensureLayout(for: textContainer)
            return layoutManager.usedRect(for: textContainer).size
        }
    }
    
    func changeThemeStyle(withStyle style: EditorThemeStyle) {
        currentThemeStyle = style
        layout()
    }
}

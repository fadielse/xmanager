//
//  Editorswift
//  Xmanager
//
//  Created by Fadilah Hasan on 21/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

enum EditorThemeStyle: String {
    case dark = "dracula"
    case light = "xcode"
}

protocol EditorTextViewDelegate {
    
    func EditorTextView(didLayoutThemeWithEditor editor: EditorTextView)
}

class EditorTextView: NSTextView {
    
    var editorDelegate: EditorTextViewDelegate?
    var currentThemeStyle: EditorThemeStyle = .dark
    var txtStorage = CodeAttributedString()
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }
    
    override func layout() {
        print("Layout")

        txtStorage.delegate = self
        txtStorage.language = "Swift"
        txtStorage.highlightr.setTheme(to: currentThemeStyle.rawValue)
        txtStorage.highlightr.theme.codeFont = NSFont(name: "Courier", size: 12)
        txtStorage.addLayoutManager(layoutManager!)
        
        autoresizingMask = .width
        backgroundColor = NSColor.textBackgroundColor
        delegate = self.delegate
        drawsBackground = true
        font = self.font
        isEditable = self.isEditable
        isHorizontallyResizable = false
        isVerticallyResizable = true
        maxSize = NSSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        minSize = NSSize(width: 0, height: 3000)
        textColor = currentThemeStyle == .dark ? .white : .black
        backgroundColor = txtStorage.highlightr.theme.themeBackgroundColor
        
        editorDelegate?.EditorTextView(didLayoutThemeWithEditor: self)
    }
    
    override func didChangeText() {
        print("didChangeText")
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

extension EditorTextView: NSTextStorageDelegate {
    
}

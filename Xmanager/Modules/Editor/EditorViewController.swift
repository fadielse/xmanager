//
//  EditorViewController.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 20/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class EditorViewController: BaseViewController {
    
    @IBOutlet weak var viewMenu: NSView!
    @IBOutlet weak var viewEditor: NSView!
    @IBOutlet var textView: EditorTextView!
    
    let textStorage = CodeAttributedString()
    
    var fileUrl: URL? {
        didSet {
            loadCodeFromFileIfExists()
        }
    }
    var syntaxText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.editorDelegate = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.wantsLayer = true
        viewMenu.wantsLayer = true
        view.window?.delegate = self
    }
    
    @IBAction func onSelectedThemeStyleMenu(_ sender: Any) {
        textView.changeThemeStyle(withStyle: .light)
    }
    
    func loadCodeFromFileIfExists() {
        guard let fileUrl = fileUrl, let text = TextParser.read(withFileUrl: fileUrl) else {
            return
        }
        
        syntaxText = text
        textView.string = text
        viewMenu.layer?.backgroundColor = textView.txtStorage.highlightr.theme.themeBackgroundColor.cgColor
    }
}

extension EditorViewController: NSWindowDelegate {
    func windowWillResize(_ sender: NSWindow, to frameSize: NSSize) -> NSSize {
        textView.string = syntaxText
        textView.layout()
        return frameSize
    }
}

extension EditorViewController: EditorTextViewDelegate {
    
    func EditorTextView(didLayoutThemeWithEditor editor: EditorTextView) {
        view.layer?.backgroundColor = editor.txtStorage.highlightr.theme.themeBackgroundColor.cgColor
    }
}

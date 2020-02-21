//
//  EditorViewController.swift
//  Xcode Template Manager
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func onSelectedThemeStyleMenu(_ sender: Any) {
        
    }
    
    func loadCodeFromFileIfExists() {
        guard let fileUrl = fileUrl, let text = TextParser.read(withFileUrl: fileUrl) else {
            return
        }
        
        textView.string = text
    }
}

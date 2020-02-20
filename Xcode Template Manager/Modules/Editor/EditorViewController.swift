//
//  EditorViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 20/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class EditorViewController: BaseViewController {

    @IBOutlet weak var viewEditor: SyntaxTextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewEditor.delegate = self
    }
}

extension EditorViewController: SyntaxTextViewDelegate {
    func lexerForSource(_ source: String) -> Lexer {
        return Lexer(lexerForSource(source))
    }
}

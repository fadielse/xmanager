//
//  NewFormViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 14/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class NewFormViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }
    
    @IBAction func onButtonClicked(_ sender: Any) {
        self.performSegue(withIdentifier: "showCreateTemplate", sender: nil)
    }
}

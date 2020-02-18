//
//  NewFormViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 14/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

protocol NewFormViewControllerDelegate {
    func newFormViewController(successCreateGroupWithViewController viewController: NewFormViewController)
}

class NewFormViewController: BaseViewController {

    @IBOutlet weak var textFieldName: NSTextField!
    
    var delegate: NewFormViewControllerDelegate?
    
    var pathUrl: URL = UrlConstant.basePath
    var fileType: EnumNewFileType = .group
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.preferredContentSize = NSMakeSize(self.view.frame.size.width, self.view.frame.size.height);
    }
    
    @IBAction func onButtonCreateClicked(_ sender: Any) {
        guard !textFieldName.stringValue.isEmpty else {
            return
        }
        createGroupIfNotExixts()
    }
    
    func createGroupIfNotExixts() {
        let fileManager = FileManager.default
        var newGroupPathUrl = pathUrl
        
        switch fileType {
        case .group:
            newGroupPathUrl = newGroupPathUrl.appendingPathComponent(textFieldName.stringValue)
        case .xctemplate:
            newGroupPathUrl = newGroupPathUrl.appendingPathComponent("\(textFieldName.stringValue).xctemplate")
        }
        
        let fileList = contentsOf(folder: pathUrl)
        if fileList.contains(newGroupPathUrl) {
            showAlert(withMessage: "Group name already exists")
        } else {
            do {
                try fileManager.createDirectory(at: newGroupPathUrl, withIntermediateDirectories: true, attributes: nil)
                self.delegate?.newFormViewController(successCreateGroupWithViewController: self)
                self.dismiss(self)
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
    }
}

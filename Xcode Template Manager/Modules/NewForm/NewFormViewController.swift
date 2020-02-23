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
    
    private func createGroupIfNotExixts() {
        let fileManager = FileManager.default
        var newPathUrl = pathUrl
        
        switch fileType {
        case .group:
            newPathUrl = newPathUrl.appendingPathComponent(textFieldName.stringValue)
        case .xctemplate:
            newPathUrl = newPathUrl.appendingPathComponent("\(textFieldName.stringValue).xctemplate")
        }
        
        let fileList = contentsOf(folder: pathUrl)
        if fileList.contains(newPathUrl) {
            showAlert(withMessage: "Group name already exists")
        } else {
            do {
                try fileManager.createDirectory(at: newPathUrl, withIntermediateDirectories: true, attributes: nil)
                
                if fileType == .xctemplate { // Generate Template Config only if file type is .xctemplate
                    guard fileType == .xctemplate, generateTemplateInfo(withPathUrl: newPathUrl) else {
                        try fileManager.removeItem(at: newPathUrl)
                        showAlert(withMessage: "Failed to generate Template Configuration")
                        return
                    }
                }
                
                self.delegate?.newFormViewController(successCreateGroupWithViewController: self)
                self.dismiss(self)
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    private func generateTemplateInfo(withPathUrl pathUrl: URL) -> Bool {
        guard let stringText = TextParser.read(withFileName: FileNameConstant.localFile.templateInfo) else { return false }
        guard TextParser.write(withName: FileNameConstant.generate.templateInfo, andText: stringText, toPathUrl: pathUrl) else { return false }
        return true
    }
}

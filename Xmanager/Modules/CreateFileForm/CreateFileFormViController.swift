//
//  CreateFileFormViController.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 27/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

protocol CreateFileFormViControllerDelegate {
    func createFileFormViController(didCreateFileWithVc vc: CreateFileFormViController)
}

class CreateFileFormViController: BaseViewController {

    @IBOutlet weak var textFieldName: NSTextField!
    @IBOutlet weak var comboBoxKindOfFile: NSComboBox!
    
    let fileManager = FileManager.default
    
    var delegate: CreateFileFormViControllerDelegate?
    var templateUrl: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textFieldName.delegate = self
    }
    
    @IBAction func onButtonCreateClicked(_ sender: Any) {
        creatingFile()
    }
    
    func creatingFile() {
        guard
            !textFieldName.stringValue.isEmpty,
            !comboBoxKindOfFile.stringValue.isEmpty else {
            showAlert(withMessage: "Please fill all Field.")
            return
        }
        
        let fileType = comboBoxKindOfFile.stringValue.lowercased()
        let fileName = "\(textFieldName.stringValue).\(fileType)"
        
        if let templateUrl = templateUrl {
            let newFileUrl = templateUrl.appendingPathComponent(fileName)
            if fileManager.fileExists(atPath: newFileUrl.path) {
                showAlert(withMessage: "Template path not found. Please try again.")
                return
            }
            guard let stringText = TextParser.read(withFileName: fileType) else {
                showAlert(withMessage: "Something went wrong when read template file.")
                return
            }
            guard TextParser.write(withName: fileName, andText: stringText, toPathUrl: templateUrl) else {
                showAlert(withMessage: "Something went wrong when create file.")
                return
            }
            self.delegate?.createFileFormViController(didCreateFileWithVc: self)
            self.dismiss(self)
        } else {
            showAlert(withMessage: "Template path not found. Please try again.")
        }
    }
}

extension CreateFileFormViController: NSTextFieldDelegate {
    func controlTextDidChange(_ obj: Notification) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789-_+").inverted as NSCharacterSet
        textFieldName.stringValue =  (self.textFieldName.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
    }
}

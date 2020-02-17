//
//  DashboardViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 11/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var containerView: NSView!
    
    let fileManager = FileManager.default
    
    var templateDetailViewController : TemplateDetailViewController!
    var welcomeViewController : WelcomeViewController!
    
    var selectedRow: Int? {
        didSet {
            tableView.reloadData()
        }
    }
    var templateList: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        templateList = contentsOf(folder: UrlConstant.basePath)
        setupTableView()
        setupContainerView()
    }

    override var representedObject: Any? {
        didSet {
             
        }
    }
    
    @IBAction func onNewButtonClicked(_ sender: Any) {
        if let newFormViewController = self.goToScreen(withStoryboardId: "NewForm", andViewControllerId: "NewFormViewController") as? NewFormViewController {
            newFormViewController.delegate = self
        }
    }
    
    func reloadData() {
        templateList = contentsOf(folder: UrlConstant.basePath)
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NSNib(nibNamed: "XcodeTemplateCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"))
    }
    
    func setupContainerView() {
        templateDetailViewController = (NSStoryboard(name: "Dashboard", bundle: nil).instantiateController(withIdentifier: "TemplateDetailViewController") as! TemplateDetailViewController)
        welcomeViewController = (NSStoryboard(name: "Dashboard", bundle: nil).instantiateController(withIdentifier: "WelcomeViewController") as! WelcomeViewController)
        
        self.addChild(templateDetailViewController)
        self.addChild(welcomeViewController)
        welcomeViewController.view.frame = self.containerView.bounds
        self.containerView.addSubview(welcomeViewController.view)
    }
    
    func showTemplateDetail() {
        guard let selectedRow = selectedRow else {
            return
        }
        
        for sView in self.containerView.subviews {
            sView.removeFromSuperview()
        }

        templateDetailViewController.directoryUrl = templateList[selectedRow]
        templateDetailViewController.view.frame = self.containerView.bounds
        self.containerView.addSubview(templateDetailViewController.view)
        templateDetailViewController.reloadContent()
    }
    
    func updateGroupName(withName name: String) {
        let pathUrl = UrlConstant.basePath
        
        guard let selectedRow = selectedRow, templateList.indices.contains(selectedRow) else {
            showAlert(withMessage: "Original Group not exists")
            return
        }
        
        let originalGroupPathUrl = templateList[selectedRow]
        let newGroupPathUrl = pathUrl.appendingPathComponent(name)
        
        let fileList = contentsOf(folder: pathUrl)
        if fileList.contains(newGroupPathUrl) {
            showAlert(withMessage: "Group name already exists")
        } else {
            do {
                try fileManager.moveItem(at: originalGroupPathUrl, to: newGroupPathUrl)
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    func deleteTemplate() {
        guard let selectedRow = selectedRow, templateList.indices.contains(selectedRow) else {
            showAlert(withMessage: "Template is not exists")
            return
        }
        
        do {
            try fileManager.removeItem(at: templateList[selectedRow])
            self.selectedRow = nil
        } catch {
            showAlert(withMessage: error.localizedDescription)
        }
    }
}

extension DashboardViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return templateList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"), owner: nil) as? XcodeTemplateCell {
            cell.delegate = self
            cell.isSelected = selectedRow == row
            cell.labelName.stringValue = templateList[row].toDirectoryName()
            cell.draw(cell.visibleRect)
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        if let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? XcodeTemplateCell {
            selectedRow = tableView.selectedRow
            cell.isSelected = true
            cell.draw(cell.visibleRect)
            showTemplateDetail()
        }
    }
}

extension DashboardViewController: NewFormViewControllerDelegate {
    func newFormViewController(successCreateGroupWithViewController viewController: NewFormViewController) {
        reloadData()
    }
}

extension DashboardViewController: XcodeTemplateCellDelegate {
    func XcodeTemplateCell(didUpdateNameWithCell cell: XcodeTemplateCell) {
        updateGroupName(withName: cell.labelName.stringValue)
        reloadData()
    }
    
    func XcodeTemplateCell(deleteGroupWithCell cell: XcodeTemplateCell) {
        let alert = showAlertConfirm(withTitle: "Warning!", andMessage: "Are you sure you would like to delete this template?")
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.deleteTemplate()
                self.reloadData()
            }
        })
    }
}

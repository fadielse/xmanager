//
//  DashboardViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 11/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa
import NotificationCenter

extension NotificationCenterConstant {
    
    static let reloadContainerView = NSNotification.Name("reloadContainerView")
}

class DashboardViewController: BaseViewController {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var containerView: NSView!
    @IBOutlet weak var buttonDeploy: NSButton!
    @IBOutlet weak var labelLog: NSTextField!
    
    let fileManager = FileManager.default
    
    var templateDetailViewController : TemplateDetailViewController!
    var welcomeViewController : WelcomeViewController!
    
    var selectedRow: Int? {
        didSet {
            if let _ = selectedRow {
                buttonDeploy.isEnabled = true
            } else {
                buttonDeploy.isEnabled = false
            }
            tableView.reloadData()
        }
    }
    var templateList: [UrlList] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.window?.delegate = self
        setupObserver()
        getGroupList()
        setupTableView()
        setupContainerView()
        updateLog(withMessage: "Finished running Xcode Template Manager")
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
    
    func setupObserver() {
        NotificationCenter.default.addObserver(forName: NotificationCenterConstant.reloadContainerView, object: nil, queue: nil) { _ in
            self.showTemplateDetail()
        }
    }
    
    func getGroupList() {
        let urlListDao = UrlListDAO(urls: contentsOf(folder: UrlConstant.basePath))
        templateList = urlListDao.urlList
        templateList = templateList.sorted { a, b -> Bool in
            return a.url!.absoluteString < b.url!.absoluteString
        }
    }
    
    func reloadData() {
        getGroupList()
        showTemplateDetail()
        tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NSNib(nibNamed: "XcodeTemplateCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"))
    }
    
    func setupContainerView() {
        templateDetailViewController = (NSStoryboard(name: "TemplateDetail", bundle: nil).instantiateController(withIdentifier: "TemplateDetailViewController") as! TemplateDetailViewController)
        welcomeViewController = (NSStoryboard(name: "Welcome", bundle: nil).instantiateController(withIdentifier: "WelcomeViewController") as! WelcomeViewController)
        
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

        templateDetailViewController.directoryUrl = templateList[selectedRow].url
        templateDetailViewController.view.frame = self.containerView.bounds
        self.containerView.addSubview(templateDetailViewController.view)
        templateDetailViewController.reloadContent()
        if let loaded = templateList[selectedRow].url?.getName() {
            updateLog(withMessage: "Success load template : \(loaded)")
        } else {
            updateLog(withMessage: "Error load template : Source not found")
        }
    }
    
    func updateLog(withMessage message: String) {
        labelLog.stringValue = message
    }
    
    func updateGroupName(withName name: String) {
        let pathUrl = UrlConstant.basePath
        
        guard let selectedRow = selectedRow, templateList.indices.contains(selectedRow), let originalGroupPathUrl = templateList[selectedRow].url else {
            showAlert(withMessage: "Original Group not exists")
            return
        }
        
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
        guard let selectedRow = selectedRow, templateList.indices.contains(selectedRow), let urlToDelete = templateList[selectedRow].url else {
            showAlert(withMessage: "Template is not exists")
            return
        }
        
        do {
            try fileManager.removeItem(at: urlToDelete)
            self.selectedRow = 0
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
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"), owner: nil) as? XcodeTemplateCell, let groupName = templateList[row].url?.getName() {
            cell.delegate = self
            cell.isSelected = selectedRow == row
            cell.labelName.stringValue = groupName
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
        getGroupList()
        selectedRow = templateList.firstIndex(where: { urlList -> Bool in
            return urlList.url == UrlConstant.basePath.appendingPathComponent(viewController.textFieldName.stringValue)
        })
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

extension DashboardViewController: NSWindowDelegate {
    
    func windowDidResize(_ notification: Notification) {
        print("window resized")
    }
}

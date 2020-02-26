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
    static let updateLog = NSNotification.Name("updateLog")
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
    
    @IBAction func onButtonDeployClicked(_ sender: Any) {
        deployTemplateToXcode()
    }
    
    func setupObserver() {
        NotificationCenter.default.addObserver(forName: NotificationCenterConstant.reloadContainerView, object: nil, queue: nil) { _ in
            self.showTemplateDetail()
        }
        NotificationCenter.default.addObserver(forName: NotificationCenterConstant.updateLog, object: nil, queue: nil) { notication in
            if let message = notication.object as? String {
                self.updateLog(withMessage: message)
            }
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
        guard let selectedRow = selectedRow, templateList.count > 0 else {
            self.containerView.replaceSubview(templateDetailViewController.view, with: welcomeViewController.view)
            return
        }
        
        for sView in self.containerView.subviews {
            sView.removeFromSuperview()
        }

        templateDetailViewController.view.frame = self.containerView.bounds
        self.containerView.addSubview(templateDetailViewController.view)
        templateDetailViewController.directoryUrl = templateList[selectedRow].url
        if let loaded = templateList[selectedRow].url?.getName() {
            updateLog(withMessage: "Success load templates : \(loaded)")
        } else {
            updateLog(withMessage: "Error load templates : Source not found")
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
    
    func deployTemplateToXcode() {
        guard
            let selectedRow = selectedRow,
            templateList.indices.contains(selectedRow),
            let path = templateList[selectedRow].url?.path,
            let folderName = templateList[selectedRow].url?.lastPathComponent
        else {
            return
        }
        
        let installedPath = UrlConstant.xcodeTemplatePath.appendingPathComponent(folderName).path
        
        do {
            if fileManager.fileExists(atPath: installedPath) {
                try fileManager.removeItem(atPath: installedPath)
                try fileManager.copyItem(atPath: path, toPath: installedPath)
            } else {
                try fileManager.copyItem(atPath: path, toPath: installedPath)
            }
            updateLog(withMessage: "\(folderName) has been successfully installed to Xcode.")
        } catch let error {
            updateLog(withMessage: "Error install template: \(error.localizedDescription)")
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
            cell.setNeedsDisplay(cell.bounds)
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        if let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? XcodeTemplateCell {
            selectedRow = tableView.selectedRow
            cell.isSelected = true
            cell.setNeedsDisplay(cell.bounds)
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
        let alert = showAlertConfirm(withTitle: "Warning!", andMessage: "Are you sure you want to delete this Group?")
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.deleteTemplate()
                self.reloadData()
            }
        })
    }
}

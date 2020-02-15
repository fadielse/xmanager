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
    
    var templateDetailViewController : TemplateDetailViewController!
    var welcomeViewController : WelcomeViewController!
    
    var selectedRow: Int?
    var templateList: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getDataFromJson()
        templateList = contentsOf(folder: UrlConstant.basePath)
        setupTableView()
        setupContainerView()
    }

    override var representedObject: Any? {
        didSet {
             
        }
    }
    
    @IBAction func onNewButtonClicked(_ sender: Any) {
        self.goToScreen(withStoryboardId: "NewForm", andViewControllerId: "NewFormViewController")
        let manager = FileManager.default
        let path = "XcodeTemplate"
        do {
            try manager.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
            showAlert(withMessage: "directory created")
        } catch let error as NSError {
            showAlert(withMessage: "Failed to create directory")
            print("Failed to create directory: \(error.localizedDescription)")
        }

        if !manager.fileExists(atPath: "\(path)/file.txt") {
            if manager.createFile(atPath: "\(path)/file.txt", contents: nil, attributes: nil) {
                showAlert(withMessage: "file created")
                print("file created")
            }
        }

        do {
            let contents = try manager.contentsOfDirectory(atPath: path)
            let urls = contents.filter { _ in return true } //.map { return folder.appendingPathComponent($0) }
            print(urls)
        } catch {
            print("url not valid")
        }
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
    
    func getDataFromJson() {
//        do {
//            let path = Bundle.main.path(forResource: "template_data", ofType: "json")
//            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
//            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
//                let templateListDao = TemplateListDAO(data: json)
//                templateList = templateListDao.templateList
//            } else {
//                print("JSONSerialization Failed")
//            }
//        } catch let error as NSError {
//            print("Failed to load: \(error.localizedDescription)")
//        }
    }
    
    func getDocumentsDirectory() -> URL {
        // find all possible documents directories for this user
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)

        // just send back the first one, which ought to be the only one
        return paths[0]
    }
    
    func createFile() {
        let str = "Test Message"
        let url = self.getDocumentsDirectory().appendingPathComponent("message.txt")

        do {
            try FileManager.default.createDirectory(at: self.getDocumentsDirectory().appendingPathComponent("/abc"), withIntermediateDirectories: true, attributes: nil)
            try str.write(to: url, atomically: true, encoding: .utf8)
            let input = try String(contentsOf: url)
            print(input)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension DashboardViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return templateList.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"), owner: nil) as? XcodeTemplateCell {
            cell.labelName.stringValue = templateList[row].toDirectoryName()
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        if let _ = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? XcodeTemplateCell {
            selectedRow = tableView.selectedRow
            showTemplateDetail()
        }
    }
}

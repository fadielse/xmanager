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
    
    var selectedRow: Int?
    var templateList: [TemplateList]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromJson()
        setupTableView()
    }

    override var representedObject: Any? {
        didSet {
             
        }
    }
    
    @IBAction func onNewButtonClicked(_ sender: Any) {
        self.goToScreen(withStoryboardId: "NewForm", andViewControllerId: "NewFormViewController")
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(NSNib(nibNamed: "XcodeTemplateCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"))
    }
    
    func getDataFromJson() {
        do {
            let path = Bundle.main.path(forResource: "template_data", ofType: "json")
            let jsonData = try Data(contentsOf: URL(fileURLWithPath: path!), options: .mappedIfSafe)
            if let json = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: Any]] {
                let templateListDao = TemplateListDAO(data: json)
                templateList = templateListDao.templateList
            } else {
                print("JSONSerialization Failed")
            }
        } catch let error as NSError {
            print("Failed to load: \(error.localizedDescription)")
        }
    }
}

extension DashboardViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return templateList?.count ?? 0
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"), owner: nil) as? XcodeTemplateCell {
            if let name = templateList?[row].name {
                cell.labelName.stringValue = name
            }
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        if let _ = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? XcodeTemplateCell {
            selectedRow = tableView.selectedRow
            self.tableView.reloadData()
        }
    }
}

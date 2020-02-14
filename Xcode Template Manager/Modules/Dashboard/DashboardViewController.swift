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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
}

extension DashboardViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
      return 10
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "XcodeTemplateCell"), owner: nil) as? XcodeTemplateCell {
            cell.labelName.stringValue = "Row \(row)"
            return cell
        }
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        if let cell = tableView.view(atColumn: 0, row: tableView.selectedRow, makeIfNecessary: true) as? XcodeTemplateCell {
            cell.showData()
            self.tableView.reloadData()
        }
    }
}

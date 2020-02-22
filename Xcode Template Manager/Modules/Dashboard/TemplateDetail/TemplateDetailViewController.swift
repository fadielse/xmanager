//
//  TemplateDetailViewController.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class TemplateDetailViewController: BaseViewController {
    
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var viewName: NSView!
    @IBOutlet weak var viewHeaderIcon: NSView!
    @IBOutlet weak var viewTemplateIcon: NSView!
    @IBOutlet weak var viewMockup: NSView!
    @IBOutlet weak var textFieldName: NSTextField!
    @IBOutlet weak var templateImageView1: NSImageView!
    @IBOutlet weak var templateImageView2: NSImageView!
    @IBOutlet weak var viewAddTemplateButton: NSView!
    @IBOutlet weak var buttonTemplateIcon: ButtonDragView!
    @IBOutlet weak var sourceTableView: TableDragView!
    @IBOutlet weak var viewFooterSourceTable: NSView!
    @IBOutlet weak var dragAndDropSourceView: DragAndDropView!
    @IBOutlet weak var textFieldPropertyTitle: NSTextField!
    @IBOutlet weak var textFieldPropertyDescription: NSTextField!
    @IBOutlet weak var textFieldPreviewName: NSTextField!
    
    let fileManager = FileManager.default
    
    var directoryUrl: URL?
    var directoryTemplateName: String?
    var templateList: [UrlList] = [] {
        didSet {
            if templateList.indices.contains(selectedTemplateIndex), let url = templateList[selectedTemplateIndex].url {
                getListTemplate(withUrl: url)
            }
        }
    }
    var fileList: [UrlList] = []  {
        didSet {
            setTemplateImage()
            setName()
            updateSourceFiles()
            collectionView.reloadData()
        }
    }
    var sourceFiles: [UrlList] = []  {
        didSet {
            toggleDragAndDropSourceView()
            sourceTableView.reloadData()
        }
    }
    var selectedTemplateIndex: Int = 0 {
        didSet {
            if templateList.indices.contains(selectedTemplateIndex), let url = templateList[selectedTemplateIndex].url {
                getListTemplate(withUrl: url)
                directoryTemplateName = "\(url.getName()).xctemplate"
            }
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        buttonTemplateIcon.delegate = self
        getListFile()
        setupCollectionView()
        setupSourceTableView()
        prepareTrackingArea()
        setProperties()
        setPreview()
    }
    
    @IBAction func onButtonAddClicked(_ sender: Any) {
        if let newFormViewController = self.goToScreen(withStoryboardId: "NewForm", andViewControllerId: "NewFormViewController") as? NewFormViewController, let directoryUrl = directoryUrl {
            newFormViewController.delegate = self
            newFormViewController.pathUrl = directoryUrl
            newFormViewController.fileType = .xctemplate
        } else {
            showAlert(withMessage: "Something went wrong.")
        }
    }
    
    @IBAction func onButtonEditNameClicked(_ sender: Any) {
        textFieldName.isEditable = true
        textFieldName.isEnabled = true
        textFieldName.becomeFirstResponder()
    }
    
    @IBAction func onButtonTemplateIconClicked(_ sender: Any) {
    }
    
    // Mark: - Some Event
    
    func myTrakingArea(control: NSControl) -> NSTrackingArea {
        return NSTrackingArea.init(rect: control.bounds,
                                   options: [.mouseEnteredAndExited, .activeAlways],
        owner: control,
        userInfo: nil)
    }
    
    override func mouseEntered(with event: NSEvent) {
        buttonTemplateIcon.title = "Drag and drop an image file here \n (.png)"
        buttonTemplateIcon.layer?.backgroundColor = ColorConstant.mouseHoverBackground.cgColor
    }
    
    override func mouseExited(with event: NSEvent) {
        buttonTemplateIcon.title = ""
        buttonTemplateIcon.layer?.backgroundColor = .clear
    }
    
    // MARK: - Private Method
    
    private func prepareTrackingArea() {
        let mouseTrackingArea = myTrakingArea(control: self.buttonTemplateIcon)
        buttonTemplateIcon.addTrackingArea(mouseTrackingArea)
    }
    
    private func setupSourceTableView() {
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        sourceTableView.dragDelegate = self
        sourceTableView.doubleAction = #selector(doubleClickOnSourceFileRow)
        
        sourceTableView.register(NSNib(nibNamed: "SourceFileTableCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SourceFileTableCell"))
        
        viewFooterSourceTable.wantsLayer = true
        viewFooterSourceTable.layer?.backgroundColor = ColorConstant.darkBackground.cgColor
        viewFooterSourceTable.layer?.borderWidth = 1.0
        viewFooterSourceTable.layer?.borderColor = NSColor.init(white: 0.7, alpha: 0.5).cgColor
    }
    
    private func updateTemplateName(withName name: String) {
        guard let directoryUrl = directoryUrl, templateList.indices.contains(selectedTemplateIndex), let originalGroupPathUrl = templateList[selectedTemplateIndex].url else {
            showAlert(withMessage: "Original Template not exists")
            return
        }
        
        let newGroupPathUrl = directoryUrl.appendingPathComponent("\(name).xctemplate")
        
        let fileList = contentsOf(folder: directoryUrl)
        if fileList.contains(newGroupPathUrl) {
            showAlert(withMessage: "Template name already exists")
        } else {
            do {
                try fileManager.moveItem(at: originalGroupPathUrl, to: newGroupPathUrl)
                getListFile()
                
                selectedTemplateIndex = templateList.firstIndex(where: { urlList -> Bool in
                    return urlList.url == directoryUrl.appendingPathComponent("\(newGroupPathUrl.getName()).xctemplate")
                }) ?? 0
                collectionView.reloadData()
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    private func processingDropTemplateIcon(withUrls urls: [URL]) {
        
        // sort by smallest image
        let sortedUrls = urls.sorted { (a, b) -> Bool in
            var aWidth: Int = 0
            var bWidth: Int = 0
            
            let aPath = a.path
            if let mditem = MDItemCreate(nil, aPath as CFString),
                let mdnames = MDItemCopyAttributeNames(mditem),
                let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
                aWidth = mdattrs["kMDItemPixelWidth"] as? Int ?? 0
            } else {
                print("Can't get attributes for \(aPath)")
                return false
            }
            
            let bPath = b.path
            if let mditem = MDItemCreate(nil, bPath as CFString),
               let mdnames = MDItemCopyAttributeNames(mditem),
               let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
                bWidth = mdattrs["kMDItemPixelWidth"] as? Int ?? 0
            } else {
                print("Can't get attributes for \(aPath)")
                return false
            }
            
            return aWidth < bWidth
        }
        
        guard let directoryTemplateName = directoryTemplateName else {
            print("Template directory not found")
            return
        }
        
        var count = 0
        for imageUrl in sortedUrls {
            guard count <= 1 else {
                break
            }
            
            let imageName = count == 0 ? "\(directoryTemplateName)/TemplateIcon.\(imageUrl.pathExtension.lowercased())" : "\(directoryTemplateName)/TemplateIcon@2x.\(imageUrl.pathExtension.lowercased())"
            
            if let copyUrl = directoryUrl?.appendingPathComponent(imageName) {
                do {
                    if fileManager.fileExists(atPath: copyUrl.path) {
                        try fileManager.removeItem(at: copyUrl)
                    }
                    try fileManager.copyItem(at: imageUrl, to: copyUrl)
                } catch let error {
                    print("Failed to set image : \(error.localizedDescription)")
                }
            } else {
                print("Failed to set image")
                break
            }
            
            count += 1
        }
        
        getListFile()
        collectionView.reloadData()
    }
    
    private func processingDropSourceFiles(withUrls urls: [URL]) {
        
        guard let directoryTemplateName = directoryTemplateName else {
            print("Template directory not found")
            return
        }
        
        for sourceUrl in urls {
            let sourceTemplatePath = "\(directoryTemplateName)/\(sourceUrl.getName())"
            
            if let copyUrl = directoryUrl?.appendingPathComponent(sourceTemplatePath) {
                do {
                    if fileManager.fileExists(atPath: copyUrl.path) {
                        try fileManager.removeItem(at: copyUrl)
                    }
                    try fileManager.copyItem(at: sourceUrl, to: copyUrl)
                } catch let error {
                    print("Failed to set image : \(error.localizedDescription)")
                }
            } else {
                print("Failed to set image")
                break
            }
        }
        
        getListFile()
        collectionView.reloadData()
    }
    
    @objc private func doubleClickOnSourceFileRow() {
        if let editorViewController = self.goToScreen(withStoryboardId: "Editor", andViewControllerId: "EditorViewController") as? EditorViewController {
            editorViewController.fileUrl = sourceFiles[sourceTableView.clickedRow].url
        }
    }
    
    // MARK: - Method
    
    func updateSourceFiles() {
        sourceFiles = fileList.filter { (file) -> Bool in
            if file.isTemplateImage1() || file.isTemplateImage2() || file.isTemplateConfiguration() { return false }
            return true
        }
    }
    
    func toggleDragAndDropSourceView() {
        dragAndDropSourceView.isHidden = !sourceFiles.isEmpty
    }
    
    func getListTemplate(withUrl url: URL) {
        let urlListDao = UrlListDAO(urls: contentsOf(folder: url))
        fileList = urlListDao.urlList
    }
    
    func getListFile() {
        if let directoryUrl = directoryUrl {
            let urlListDao = UrlListDAO(urls: contentsOf(folder: directoryUrl))
            templateList = urlListDao.urlList.sorted { a, b -> Bool in
                return a.url!.absoluteString < b.url!.absoluteString
            }
            
            if urlListDao.isEmptyList() {
                updateViewForEmptyGroup()
            } else {
                updateViewForTemplate()
            }
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 160.0, height: 35.0)
        flowLayout.sectionInset = NSEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        flowLayout.scrollDirection = .horizontal
        collectionView.collectionViewLayout = flowLayout
    }
    
    func reloadContent() {
        selectedTemplateIndex = 0
        getListFile()
        collectionView.reloadData()
    }
    
    func setName() {
        textFieldName.delegate = self
        textFieldName.isEditable = false
        textFieldName.isEnabled = false
        if templateList.indices.contains(selectedTemplateIndex), let name = templateList[selectedTemplateIndex].url?.getName() {
            textFieldName.stringValue = name
        }
    }
    
    func setProperties() {
        textFieldPropertyTitle.delegate = self
        textFieldPropertyDescription.delegate = self
    }
    
    func setPreview() {
        textFieldPreviewName.delegate = self
    }
    
    func setTemplateImage() {
        templateImageView1.image = NSImage(named: "img-square-placeholder")
        templateImageView2.image = NSImage(named: "img-square-placeholder")
        
        for item in fileList {
            if item.isTemplateImage1(), let url = item.url {
                templateImageView1.image = NSImage(byReferencing: url)
            } else if item.isTemplateImage2(), let url = item.url {
                templateImageView2.image = NSImage(byReferencing: url)
            }
        }
    }
    
    func updateViewForEmptyGroup() {
        viewName.isHidden = true
        viewHeaderIcon.isHidden = true
        viewTemplateIcon.isHidden = true
        viewMockup.isHidden = true
    }
    
    func updateViewForTemplate() {
        viewName.isHidden = false
        viewHeaderIcon.isHidden = false
        viewTemplateIcon.isHidden = false
        viewMockup.isHidden = false
    }
}

// MARK: - NSCollection Delegate and Data Source

extension TemplateDetailViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return templateList.count
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
      
        if let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TemplateNameCell"), for: indexPath) as? TemplateNameCell {
            cell.isSelected = selectedTemplateIndex == indexPath.item
            
            if templateList.indices.contains(indexPath.item) {
                cell.labelName.stringValue = templateList[indexPath.item].url?.getName() ?? ""
            }
            
            return cell
        }
        
        return NSCollectionViewItem()
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        guard let indexPath = indexPaths.first else {
            return
        }
        
        selectedTemplateIndex = indexPath.item
    }
}

// MARK: - NewFormViewControllerDelegate

extension TemplateDetailViewController: NewFormViewControllerDelegate {
    
    func newFormViewController(successCreateGroupWithViewController viewController: NewFormViewController) {
        guard let directoryUrl = directoryUrl else {
            return
        }
        
        getListFile()
        
        selectedTemplateIndex = templateList.firstIndex(where: { urlList -> Bool in
            return urlList.url == directoryUrl.appendingPathComponent("\(viewController.textFieldName.stringValue).xctemplate")
        }) ?? 0
        
        collectionView.reloadData()
    }
}

// MARK: - NSTextFieldDelegate

extension TemplateDetailViewController: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            switch control {
            case textFieldName:
                guard !textFieldName.stringValue.isEmpty else {
                    textFieldName.resignFirstResponder()
                    textFieldName.isEditable = false
                    textFieldName.isEnabled = false
                    textFieldName.stringValue = templateList[selectedTemplateIndex].url?.getName() ?? ""
                    return false
                }
                
                textFieldName.resignFirstResponder()
                textFieldName.isEditable = false
                textFieldName.isEnabled = false
                updateTemplateName(withName: textFieldName.stringValue)
            case textFieldPropertyTitle:
                textFieldPropertyTitle.resignFirstResponder()
                textFieldPropertyTitle.isEnabled = false
                textFieldPropertyTitle.isEnabled = true
            case textFieldPropertyDescription:
                textFieldPropertyDescription.resignFirstResponder()
                textFieldPropertyDescription.isEnabled = false
                textFieldPropertyDescription.isEnabled = true
            case textFieldPreviewName:
                textFieldPreviewName.resignFirstResponder()
                textFieldPreviewName.isEnabled = false
                textFieldPreviewName.isEnabled = true
            default:
                view.resignFirstResponder()
            }
            
            return true
        } else if (commandSelector == #selector(NSResponder.cancelOperation(_:))) {
            
            switch control {
            case textFieldName:
                textFieldName.resignFirstResponder()
                textFieldName.isEditable = false
                textFieldName.isEnabled = false
            case textFieldPropertyTitle:
                textFieldPropertyTitle.resignFirstResponder()
                textFieldPropertyTitle.isEnabled = false
                textFieldPropertyTitle.isEnabled = true
            case textFieldPropertyDescription:
                textFieldPropertyDescription.resignFirstResponder()
                textFieldPropertyDescription.isEnabled = false
                textFieldPropertyDescription.isEnabled = true
            case textFieldPreviewName:
                textFieldPreviewName.resignFirstResponder()
                textFieldPreviewName.isEnabled = false
                textFieldPreviewName.isEnabled = true
            default:
                view.resignFirstResponder()
            }
        }
        return false
    }
}

// MARK: - ButtonDragViewDelegate

extension TemplateDetailViewController: ButtonDragViewDelegate {
    
    func buttonDragView(didDragFileWithUrls urls: [URL]) {
        processingDropTemplateIcon(withUrls: urls)
    }
}

// MARK: - NSTableViewDelegate, NSTableViewDataSource, TableDragViewDelegate

extension TemplateDetailViewController: NSTableViewDelegate, NSTableViewDataSource, TableDragViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return sourceFiles.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SourceFileTableCell"), owner: nil) as? SourceFileTableCell,
            sourceFiles.indices.contains(row) else {
            return nil
        }
        
        guard let fileName = sourceFiles[row].url?.getName() else { return nil }
        
        cell.labelName.stringValue = fileName
        cell.labelName.toolTip = fileName
        return cell
    }
    
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        guard sourceFiles.indices.contains(row) else { return true }
        guard sourceFiles[row].isTemplateConfiguration() else { return true }
        return false
    }
    
    func tableDragView(didDragFileWithUrls urls: [URL]) {
        processingDropSourceFiles(withUrls: urls)
    }
}

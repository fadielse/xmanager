//
//  TemplateDetailViewController.swift
//  Xmanager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class TemplateDetailViewController: BaseViewController {
    
    enum EnumSourceOpenOptionMenu: String {
        case open = "Open"
        case openWith = "Open With"
        case xcode = "Xcode"
        case textEdit = "Text Edit"
        case delete = "Delete"
        case rename = "Rename"
    }
    
    enum EnumButtonAddSourceMenu: String {
        case createNew = "Create New File"
        case browseFiles = "Browse File's"
    }
    
    @IBOutlet weak var viewTemplateList: NSView!
    @IBOutlet weak var collectionView: NSCollectionView!
    @IBOutlet weak var viewName: NSView!
    @IBOutlet weak var viewHeaderIcon: NSView!
    @IBOutlet weak var viewTemplateIcon: NSView!
    @IBOutlet weak var textFieldName: NSTextField!
    @IBOutlet weak var templateImageView1: NSImageView!
    @IBOutlet weak var templateImageView2: NSImageView!
    @IBOutlet weak var viewAddTemplateButton: NSView!
    @IBOutlet weak var buttonTemplateIcon: ButtonDragView!
    
    // Source Files Area
    @IBOutlet weak var viewMockup: NSView!
    @IBOutlet weak var sourceTableView: TableDragView!
    @IBOutlet weak var viewFooterSourceTable: NSView!
    @IBOutlet weak var dragAndDropSourceView: DragAndDropView!
    @IBOutlet weak var buttonAddSourceFile: NSButton!
    
    // Properties Area
    @IBOutlet weak var viewProperties: NSView!
    @IBOutlet weak var textFieldPropertyIdentifier: NSTextField!
    @IBOutlet weak var textFieldPropertyTitle: NSTextField!
    @IBOutlet weak var textFieldPropertyDescription: NSTextField!
    
    // Preview Area
    @IBOutlet weak var viewPreview: NSView!
    @IBOutlet weak var labelPreviewName: NSTextField!
    @IBOutlet weak var textFieldPreviewName: NSTextField!
    @IBOutlet weak var viewGeneratedFile1: NSView!
    @IBOutlet weak var labelGeneratedFile1: NSTextField!
    @IBOutlet weak var viewGeneratedFile2: NSView!
    @IBOutlet weak var labelGeneratedFile2: NSTextField!
    @IBOutlet weak var viewGeneratedFile3: NSView!
    @IBOutlet weak var labelGeneratedFile3: NSTextField!
    @IBOutlet weak var viewGeneratedFile4: NSView!
    @IBOutlet weak var labelGeneratedFile4: NSTextField!
    @IBOutlet weak var viewGeneratedFile5: NSView!
    
    // Danger Area
    @IBOutlet weak var viewDeleteTemplate: NSView!
    @IBOutlet weak var labelGeneratedFile5: NSTextField!
    
    let fileManager = FileManager.default
    
    var directoryTemplateName: String?
    var directoryUrl: URL? {
        didSet {
            getListFile()
            reloadContent()
        }
    }
    var templateInfo: TemplateInfo? {
        didSet {
            loadTemplateProperties()
            updatePreview()
        }
    }
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
                directoryTemplateName = "\(url.getTemplateName()).xctemplate"
                loadTemplateConfiguration()
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
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose your icon's"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedFileTypes        = ["png"]

        dialog.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.processingDropTemplateIcon(withUrls: dialog.urls)
            } else {
                self.postUpdateLog(withMessage: "Failed to get file's")
            }
        }
    }
    
    @IBAction func onButtonAddSourceClicked(_ sender: Any) {
        if let event = NSApplication.shared.currentEvent {
            let menu = NSMenu()
            menu.addItem(NSMenuItem(title: EnumButtonAddSourceMenu.createNew.rawValue, action: #selector(openFormNewFile(_:)), keyEquivalent: ""))
            menu.addItem(NSMenuItem(title: EnumButtonAddSourceMenu.browseFiles.rawValue, action: #selector(openPanelBrowseFile  ), keyEquivalent: ""))
            NSMenu.popUpContextMenu(menu, with: event, for: buttonAddSourceFile)
        }
    }
    
    @IBAction func onButtonDeleteTemplateClicked(_ sender: Any) {
        let alert = showAlertConfirm(withTitle: "Warning!", andMessage: "Are you sure you want to delete this template?")
        alert.beginSheetModal(for: self.view.window!, completionHandler: { (modalResponse) -> Void in
            if modalResponse == NSApplication.ModalResponse.alertFirstButtonReturn {
                self.deleteTemplate()
                self.selectedTemplateIndex = 0
                self.reloadContent()
            }
        })
    }
    
    @IBAction func onButtonDeleteSourceClicked(_ sender: Any) {
        deleteSourceFiles()
        updateTemplateConfiguration()
        reloadContent()
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
    
    // MARK: -  Method
    
    func prepareTrackingArea() {
        let mouseTrackingArea = myTrakingArea(control: self.buttonTemplateIcon)
        buttonTemplateIcon.addTrackingArea(mouseTrackingArea)
    }
    
    func setupSourceTableView() {
        sourceTableView.delegate = self
        sourceTableView.dataSource = self
        sourceTableView.dragDelegate = self
        sourceTableView.doubleAction = #selector(doubleClickOnSourceFileRow)
        
        let menu = NSMenu()
        let menuItemOpen = NSMenuItem(title: EnumSourceOpenOptionMenu.open.rawValue, action: #selector(selectedMenuTableRow(_:)), keyEquivalent: "")
        let menuItemOpenWith = NSMenuItem(title: EnumSourceOpenOptionMenu.openWith.rawValue, action: #selector(selectedMenuTableRow(_:)), keyEquivalent: "")
        menu.addItem(menuItemOpen)
        menu.addItem(menuItemOpenWith)
        menu.addItem(NSMenuItem(title: EnumSourceOpenOptionMenu.rename.rawValue, action: #selector(selectedMenuTableRow(_:)), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: EnumSourceOpenOptionMenu.delete.rawValue, action: #selector(selectedMenuTableRow(_:)), keyEquivalent: ""))
        
        let submenu = NSMenu()
        submenu.addItem(NSMenuItem(title: EnumSourceOpenOptionMenu.xcode.rawValue, action: #selector(selectedMenuTableRow(_:)), keyEquivalent: ""))
        submenu.addItem(NSMenuItem(title: EnumSourceOpenOptionMenu.textEdit.rawValue, action: #selector(selectedMenuTableRow(_:)), keyEquivalent: ""))
        
        menu.setSubmenu(submenu, for: menu.item(at: 1)!)
        sourceTableView.menu = menu
        
        sourceTableView.register(NSNib(nibNamed: "SourceFileTableCell", bundle: nil), forIdentifier: NSUserInterfaceItemIdentifier(rawValue: "SourceFileTableCell"))
        
        viewFooterSourceTable.wantsLayer = true
        viewFooterSourceTable.layer?.backgroundColor = ColorConstant.darkBackground.cgColor
        viewFooterSourceTable.layer?.borderWidth = 1.0
        viewFooterSourceTable.layer?.borderColor = NSColor.init(white: 0.7, alpha: 0.5).cgColor
    }
    
    func startRenameSourceFile(withIndex index: Int) {
        guard sourceFiles.indices.contains(index), let fileUrl = sourceFiles[index].url else { return }
        if let cell = sourceTableView.view(atColumn: 0, row: index, makeIfNecessary: true) as? SourceFileTableCell {
            cell.startEditing(withFileUrl: fileUrl)
        }
    }
    
    func updateTemplateName(withName name: String) {
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
                    return urlList.url == directoryUrl.appendingPathComponent("\(newGroupPathUrl.getTemplateName()).xctemplate")
                }) ?? 0
                collectionView.reloadData()
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    func updateSourceFileName(withName name: String, andFileUrl fileUrl: URL) {
        let newFilePathUrl = fileUrl.getPathOnly().appendingPathComponent("\(name)")
        
        let sourcefileList = contentsOf(folder: fileUrl.getPathOnly())
        if sourcefileList.contains(newFilePathUrl) {
            showAlert(withMessage: "File name already exists")
        } else {
            do {
                try fileManager.moveItem(at: fileUrl, to: newFilePathUrl)
                collectionView.reloadData()
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
        
        getListFile()
        updateTemplateConfiguration()
        loadTemplateConfiguration()
        updateTemplateProperties()
        updatePreview()
        collectionView.reloadData()
    }
    
    func processingDropTemplateIcon(withUrls urls: [URL]) {
        
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
                self.postUpdateLog(withMessage: "Can't get attributes for \(aPath)")
                return false
            }
            
            let bPath = b.path
            if let mditem = MDItemCreate(nil, bPath as CFString),
               let mdnames = MDItemCopyAttributeNames(mditem),
               let mdattrs = MDItemCopyAttributes(mditem, mdnames) as? [String:Any] {
                bWidth = mdattrs["kMDItemPixelWidth"] as? Int ?? 0
            } else {
                self.postUpdateLog(withMessage: "Can't get attributes for \(bPath)")
                return false
            }
            
            return aWidth < bWidth
        }
        
        guard let directoryTemplateName = directoryTemplateName else {
            self.postUpdateLog(withMessage: "Template directory not found")
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
                    self.postUpdateLog(withMessage: "Failed to set image : \(error.localizedDescription)")
                }
            } else {
                self.postUpdateLog(withMessage: "Failed to set image")
                break
            }
            
            count += 1
        }
        
        getListFile()
        collectionView.reloadData()
    }
    
    func processingDropSourceFiles(withUrls urls: [URL]) {
        
        guard let directoryTemplateName = directoryTemplateName else {
            self.postUpdateLog(withMessage: "Template directory not found")
            return
        }
        
        for sourceUrl in urls {
            let sourceTemplatePath = "\(directoryTemplateName)/\(sourceUrl.getTemplateName())"
            
            if let copyUrl = directoryUrl?.appendingPathComponent(sourceTemplatePath) {
                do {
                    if fileManager.fileExists(atPath: copyUrl.path) {
                        try fileManager.removeItem(at: copyUrl)
                    }
                    try fileManager.copyItem(at: sourceUrl, to: copyUrl)
                } catch let error {
                    self.postUpdateLog(withMessage: "Failed to copy File : \(error.localizedDescription)")
                }
            } else {
                self.postUpdateLog(withMessage: "Failed to copy File")
                break
            }
        }
        
        getListFile()
        updateTemplateConfiguration()
        loadTemplateConfiguration()
        updateTemplateProperties()
        updatePreview()
        collectionView.reloadData()
    }
    
    func loadTemplateProperties() {
        guard let templateInfo = templateInfo else { return }
        textFieldPropertyIdentifier.stringValue = templateInfo.getPropertyIdentifier()
        textFieldPropertyTitle.stringValue = templateInfo.getPropertyTitle()
        textFieldPropertyDescription.stringValue = templateInfo.getPropertyDescription()
    }
    
    func updateTemplateProperties() {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ ").inverted as NSCharacterSet
        textFieldPropertyTitle.stringValue =  (self.textFieldPropertyTitle.stringValue.components(separatedBy: characterSet as CharacterSet) as NSArray).componentsJoined(by: "")
//        textFieldPropertyIdentifier.stringValue = textFieldPropertyTitle.stringValue.removeWhiteSpace()
    }
    
    func updatePreview() {
        guard let templateInfo = templateInfo else {
            viewGeneratedFile1.isHidden = true
            viewGeneratedFile2.isHidden = true
            viewGeneratedFile3.isHidden = true
            viewGeneratedFile4.isHidden = true
            viewGeneratedFile5.isHidden = true
            return
        }
        labelPreviewName.stringValue = textFieldPropertyTitle.stringValue
        labelPreviewName.toolTip = textFieldPropertyDescription.stringValue
        labelPreviewName.stringValue = "\(textFieldPropertyTitle.stringValue):"
        
        viewGeneratedFile1.isHidden = templateInfo.isGenerateFileHidden(withIndex: TemplateInfoOptionRows.generateFile1)
        viewGeneratedFile2.isHidden = templateInfo.isGenerateFileHidden(withIndex: TemplateInfoOptionRows.generateFile2)
        viewGeneratedFile3.isHidden = templateInfo.isGenerateFileHidden(withIndex: TemplateInfoOptionRows.generateFile3)
        viewGeneratedFile4.isHidden = templateInfo.isGenerateFileHidden(withIndex: TemplateInfoOptionRows.generateFile4)
        viewGeneratedFile5.isHidden = templateInfo.isGenerateFileHidden(withIndex: TemplateInfoOptionRows.generateFile5)
        
        labelGeneratedFile1.stringValue = viewGeneratedFile1.isHidden ? "" : getGenerateFileLabelString(withIndex: TemplateInfoOptionRows.generateFile1)
        labelGeneratedFile2.stringValue = viewGeneratedFile2.isHidden ? "" : getGenerateFileLabelString(withIndex: TemplateInfoOptionRows.generateFile2)
        labelGeneratedFile3.stringValue = viewGeneratedFile3.isHidden ? "" : getGenerateFileLabelString(withIndex: TemplateInfoOptionRows.generateFile3)
        labelGeneratedFile4.stringValue = viewGeneratedFile4.isHidden ? "" : getGenerateFileLabelString(withIndex: TemplateInfoOptionRows.generateFile4)
        labelGeneratedFile5.stringValue = viewGeneratedFile5.isHidden ? "" : getGenerateFileLabelString(withIndex: TemplateInfoOptionRows.generateFile5)
    }
    
    func getGenerateFileLabelString(withIndex index: Int) -> String {
        guard let templateInfo = templateInfo else { return "" }
        let stringToRaplace = templateInfo.options[index].getDefaultValue().between("___", "___") ?? ""
        
        var newValue = ""
        
        if textFieldPreviewName.stringValue.isEmpty {
            newValue = templateInfo.options[index].getDefaultValue().replacingOccurrences(of: stringToRaplace, with: "VARIABLE_\(textFieldPropertyIdentifier.stringValue):identifier")
        } else {
            newValue = templateInfo.options[index].getDefaultValue().replacingOccurrences(of: "___\(stringToRaplace)___", with: textFieldPreviewName.stringValue)
        }
        
        return newValue
    }
    
    func updateTemplateConfiguration() {
        guard let templateInfo = templateInfo else { return }
        var plist = ""
        plist.append(templateInfo.getMainPlistFormat(withName: textFieldPropertyTitle.stringValue, andDescription: textFieldPropertyDescription.stringValue))
        var index = 1
        for file in sourceFiles {
            if index > 5 { break }
            if file.hasTemplateCode() {
                plist.append(file.getGenerateFilePlistFormat(withIndex: index, andIdentifier: textFieldPropertyTitle.stringValue.removeWhiteSpace()))
            }
            index = index + 1
        }
        plist.append(templateInfo.getClosurePlistFormat())
        
        if let url = templateList[selectedTemplateIndex].url, fileManager.fileExists(atPath: url.appendingPathComponent(FileNameConstant.generate.templateInfo).path) {
            do {
                try fileManager.removeItem(atPath: url.appendingPathComponent(FileNameConstant.generate.templateInfo).path)
                
                if !TextParser.write(withName: FileNameConstant.generate.templateInfo, andText: plist, toPathUrl: url) {
                    self.postUpdateLog(withMessage: "Error write template configuration")
                }
            } catch let error {
                self.postUpdateLog(withMessage: "Error write template configuration: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteTemplate() {
        if let url = templateList[selectedTemplateIndex].url, fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(atPath: url.path)
            } catch let error {
                self.postUpdateLog(withMessage: "Failed to delete template: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteSourceFiles() {
        var indexToRemove: [Int] = []
        for (_, index) in sourceTableView.selectedRowIndexes.enumerated() {
            if let url = sourceFiles[index].url, fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(atPath: url.path)
                    indexToRemove.append(index)
                } catch let error {
                    self.postUpdateLog(withMessage: "Failed to delete file's: \(error.localizedDescription)")
                }
            } else {
                self.postUpdateLog(withMessage: "File already deleted")
                indexToRemove.append(index)
            }
        }
        
        let indexSet: Set = Set(indexToRemove)
        sourceFiles = sourceFiles.enumerated()
            .filter { !indexSet.contains($0.offset) }
            .map { $0.element }
    }
    
    func deleteSourceFile(withIndex index: Int) {
        if let url = sourceFiles[index].url, fileManager.fileExists(atPath: url.path) {
            do {
                try fileManager.removeItem(atPath: url.path)
                sourceFiles.remove(at: index)
            } catch let error {
                self.postUpdateLog(withMessage: "Failed to delete file: \(error.localizedDescription)")
            }
        } else {
            self.postUpdateLog(withMessage: "File already deleted")
            sourceFiles.remove(at: index)
        }
    }
    
    func postUpdateLog(withMessage message: String) {
        NotificationCenter.default.post(name: NotificationCenterConstant.updateLog, object: message)
    }
    
    func openFileWithDefaultApp(path: String) {
        NSWorkspace.shared.openFile(path)
    }
    
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
                updateViewForExistsTemplate()
            }
        }
    }
    
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: 170.0, height: 35.0)
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
        if templateList.indices.contains(selectedTemplateIndex), let name = templateList[selectedTemplateIndex].url?.getTemplateName() {
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
        viewProperties.isHidden = true
        viewPreview.isHidden = true
        viewDeleteTemplate.isHidden = true
    }
    
    func updateViewForExistsTemplate() {
        viewName.isHidden = false
        viewHeaderIcon.isHidden = false
        viewTemplateIcon.isHidden = false
        viewMockup.isHidden = false
        viewProperties.isHidden = false
        viewPreview.isHidden = false
        viewDeleteTemplate.isHidden = false
    }
    
    // Load Template Configuration
    func loadTemplateConfiguration() {
        guard templateList.count > 0 else {
            return
        }
        
        if let path = templateList[selectedTemplateIndex].url?.appendingPathComponent("TemplateInfo.plist").path {
            templateInfo = TemplateInfo(withDictionary: NSDictionary(contentsOfFile: path))
        }
    }
    
    @objc func openPanelBrowseFile() {
        let dialog = NSOpenPanel()
        
        dialog.title                   = "Choose your file's"
        dialog.showsResizeIndicator    = true
        dialog.showsHiddenFiles        = false
        dialog.canChooseDirectories    = false
        dialog.canCreateDirectories    = false
        dialog.allowsMultipleSelection = true
        dialog.allowedFileTypes        = ["swift", "h", "m", "storyboard", "xib"]

        dialog.begin { (result) -> Void in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self.processingDropSourceFiles(withUrls: dialog.urls)
            } else {
                self.postUpdateLog(withMessage: "Failed to get file's")
            }
        }
    }
    
    @objc func selectedMenuTableRow(_ sender: NSMenuItem) {
        guard sourceFiles.indices.contains(sourceTableView.clickedRow) else { return }
        guard let path = sourceFiles[sourceTableView.clickedRow].url?.path else { return }
        
        switch EnumSourceOpenOptionMenu(rawValue: sender.title) {
        case .open:
            NSWorkspace.shared.openFile(path)
        case .openWith:
            print("do nothing")
        case .xcode:
            NSWorkspace.shared.openFile(path, withApplication: "Xcode")
        case .textEdit:
            NSWorkspace.shared.openFile(path, withApplication: "TextEdit")
        case .rename:
            startRenameSourceFile(withIndex: sourceTableView.clickedRow)
        case .delete:
            deleteSourceFile(withIndex: sourceTableView.clickedRow)
            updateTemplateConfiguration()
            reloadContent()
        default:
            NSWorkspace.shared.openFile(path)
        }
    }
    
    @objc func doubleClickOnSourceFileRow() {
        guard sourceFiles.indices.contains(sourceTableView.clickedRow) else { return }
        if let filePath = sourceFiles[sourceTableView.clickedRow].url?.path {
            openFileWithDefaultApp(path: filePath)
        }
    }
    
    @objc func openFormNewFile(_ sender: NSMenuItem) {
        if let createFileFormViController = goToScreen(withStoryboardId: "CreateFileForm", andViewControllerId: "CreateFileFormViController") as? CreateFileFormViController {
            createFileFormViController.delegate = self
            createFileFormViController.templateUrl = templateList[selectedTemplateIndex].url
        }
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
                cell.labelName.stringValue = templateList[indexPath.item].url?.getTemplateName() ?? ""
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
                    textFieldName.stringValue = templateList[selectedTemplateIndex].url?.getTemplateName() ?? ""
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
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        
        if textField == textFieldPropertyTitle {
            textFieldPreviewName.stringValue = ""
            updateTemplateProperties()
            updateTemplateConfiguration()
            loadTemplateConfiguration()
            updatePreview()
        } else if textField == textFieldPropertyDescription {
            updateTemplateProperties()
            updateTemplateConfiguration()
            loadTemplateConfiguration()
            updatePreview()
        } else if textField == textFieldPreviewName {
            updatePreview()
        }
    }
    
    func controlTextDidEndEditing(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else {
            return
        }
        
        if textField == textFieldPropertyTitle {
        }
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
        
        guard let fileName = sourceFiles[row].url?.getTemplateName() else { return nil }
        cell.delegate = self
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


// MARK: - XMLParser Delegate

extension TemplateDetailViewController: XMLParserDelegate {
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        print(attributeDict)
    }
}

// MARK: - SourceTableViewDelegate

extension TemplateDetailViewController: SourceFileTableCellDelegate {
    
    func SourceFileTableCell(updateFileName name: String, withUrl url: URL) {
        updateSourceFileName(withName: name, andFileUrl: url)
    }
}

// MARK: - CreateFileFormViControllerDelegate

extension TemplateDetailViewController: CreateFileFormViControllerDelegate {
    func createFileFormViController(didCreateFileWithVc vc: CreateFileFormViController) {
        getListFile()
        updateTemplateConfiguration()
        loadTemplateConfiguration()
        updateTemplateProperties()
        updatePreview()
        collectionView.reloadData()
    }
}

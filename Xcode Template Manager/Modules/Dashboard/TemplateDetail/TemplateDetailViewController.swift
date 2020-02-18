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
    
    let fileManager = FileManager.default
    
    var directoryUrl: URL?
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
            collectionView.reloadData()
        }
    }
    var selectedTemplateIndex: Int = 0 {
        didSet {
            if templateList.indices.contains(selectedTemplateIndex), let url = templateList[selectedTemplateIndex].url {
                getListTemplate(withUrl: url)
            }
            collectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        getListFile()
        setupCollectionView()
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
    
    // MARK: - Private Method
    
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
                    return urlList.url == directoryUrl.appendingPathComponent("\(newGroupPathUrl.toDirectoryName()).xctemplate")
                }) ?? 0
                collectionView.reloadData()
            } catch {
                showAlert(withMessage: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Method
    
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
    
    func getListTemplate(withUrl url: URL) {
        let urlListDao = UrlListDAO(urls: contentsOf(folder: url))
        fileList = urlListDao.urlList
    }
    
    func setName() {
        textFieldName.delegate = self
        textFieldName.isEditable = false
        textFieldName.isEnabled = false
        if templateList.indices.contains(selectedTemplateIndex), let name = templateList[selectedTemplateIndex].url?.toDirectoryName() {
            textFieldName.stringValue = name
        }
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

extension TemplateDetailViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return templateList.count
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
      
        if let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TemplateNameCell"), for: indexPath) as? TemplateNameCell {
            cell.isSelected = selectedTemplateIndex == indexPath.item
            
            if templateList.indices.contains(indexPath.item) {
                cell.labelName.stringValue = templateList[indexPath.item].url?.toDirectoryName() ?? ""
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

extension TemplateDetailViewController: NSTextFieldDelegate {
    
    func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {
        if (commandSelector == #selector(NSResponder.insertNewline(_:))) {
            guard !textFieldName.stringValue.isEmpty else {
                textFieldName.resignFirstResponder()
                textFieldName.isEditable = false
                textFieldName.isEnabled = false
                textFieldName.stringValue = templateList[selectedTemplateIndex].url?.toDirectoryName() ?? ""
                return false
            }
            
            textFieldName.resignFirstResponder()
            textFieldName.isEditable = false
            textFieldName.isEnabled = false
            updateTemplateName(withName: textFieldName.stringValue)
            return true
        }
        
        return false
    }
}

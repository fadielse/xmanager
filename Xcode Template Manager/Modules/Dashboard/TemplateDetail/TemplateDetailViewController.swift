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
    @IBOutlet weak var templateImageView1: NSImageView!
    @IBOutlet weak var templateImageView2: NSImageView!
    
    var directoryUrl: URL?
    var templateList: [UrlList] = [] {
        didSet {
            if let url = templateList.first?.url {
                getListTemplate(withUrl: url)
            }
        }
    }
    var fileList: [UrlList] = []  {
           didSet {
               setTemplateImage()
           }
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getListFile()
        setupCollectionView()
    }
    
    func getListFile() {
        if let directoryUrl = directoryUrl {
            let urlListDao = UrlListDAO(urls: contentsOf(folder: directoryUrl))
            templateList = urlListDao.urlList
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
        view.wantsLayer = true
        
        if let url = templateList.first?.url {
            getListTemplate(withUrl: url)
        }
    }
    
    func reloadContent() {
        getListFile()
        collectionView.reloadData()
    }
    
    func getListTemplate(withUrl url: URL) {
        let urlListDao = UrlListDAO(urls: contentsOf(folder: url))
        fileList = urlListDao.urlList
    }
    
    func setTemplateImage() {
        for item in fileList {
            if item.isTemplateImage1(), let url = item.url {
                templateImageView1.image = NSImage(byReferencing: url)
            } else if item.isTemplateImage2(), let url = item.url {
                templateImageView2.image = NSImage(byReferencing: url)
            }
        }
    }
}

extension TemplateDetailViewController: NSCollectionViewDelegate, NSCollectionViewDataSource {
    
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return templateList.count
    }
    
    func collectionView(_ itemForRepresentedObjectAtcollectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
      
        if let cell = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "TemplateNameCell"), for: indexPath) as? TemplateNameCell {
            cell.labelName.stringValue = templateList[indexPath.item].url?.toDirectoryName() ?? ""
            return cell
        }
        
        return NSCollectionViewItem()
    }
    
    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    }
}

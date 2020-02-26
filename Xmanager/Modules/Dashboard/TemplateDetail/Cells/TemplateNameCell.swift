//
//  TemplateNameCell.swift
//  Xcode Template Manager
//
//  Created by Fadilah Hasan on 15/02/20.
//  Copyright © 2020 Fadilah Hasan. All rights reserved.
//

import Cocoa

class TemplateNameCell: NSCollectionViewItem {

    @IBOutlet var contentView: NSView!
    @IBOutlet weak var labelName: NSTextField!
    
    let normalColor: CGColor = ColorConstant.darkBackground.cgColor
    let selectedColor: CGColor = ColorConstant.darkBlue.cgColor
    
    override var isSelected: Bool {
        didSet {
            super.isSelected = isSelected
            updateSelection()
            // Do other stuff if needed
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.wantsLayer = true
        updateSelection()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        updateSelection()
    }
    
    private func updateSelection() {
        view.layer?.backgroundColor = isSelected ? self.selectedColor : self.normalColor
    }
}

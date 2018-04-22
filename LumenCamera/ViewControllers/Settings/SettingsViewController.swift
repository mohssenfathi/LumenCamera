//
//  SettingsViewController.swift
//  LumenCamera
//
//  Created by Mohssen Fathi on 3/14/18.
//  Copyright © 2018 mohssenfathi. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var formatSlideButton: SlideButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setup()
    }
    
    func setup() {
        fileFormatSection()
    }
    
    @IBAction func closeButtonPressed(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Sections
    
    /// File Format
    func fileFormatSection() {
        
        let index: Int = Preference.captureFormat.getValue() ?? 0
        formatSlideButton.selectIndex(index)
        
        formatSlideButton.items = [
            "JPEG", "PNG", "RAW"
        ]
    }
    
    @IBAction func formatChanged(_ sender: SlideButton) {
        Preference.captureFormat.update(to: sender.selectedIndex)
    }
    
}

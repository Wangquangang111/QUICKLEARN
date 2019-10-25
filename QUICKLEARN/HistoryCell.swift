//
//  HistoryCell.swift
//  QUICKLEARN
//
//  Created by  wangquangang on 2019/10/25.
//  Copyright © 2019 wangquangang. All rights reserved.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var englishTextView: UITextView!
    @IBOutlet weak var chineseTextView: UITextView!

    override func awakeFromNib() {
        englishTextView.clipsToBounds = true
        englishTextView.layer.cornerRadius = 5
        englishTextView.layer.borderWidth = 0.5
        englishTextView.layer.borderColor = UIColor.lightGray.cgColor
        englishTextView.isEditable = false

        chineseTextView.clipsToBounds = true
        chineseTextView.layer.cornerRadius = 5
        chineseTextView.layer.borderWidth = 0.5
        chineseTextView.layer.borderColor = UIColor.lightGray.cgColor
        chineseTextView.isEditable = false
    }
}

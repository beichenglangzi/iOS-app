//
//  ResumeDetailCell.swift
//  resume_builder
//
//  Created by Ricky  Feig on 3/17/21.
//

import UIKit

class ResumeDetailCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var wrapper: UIView!
    @IBOutlet weak var desc: UITextView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        wrapper.backgroundColor = .systemGreen
    }
}


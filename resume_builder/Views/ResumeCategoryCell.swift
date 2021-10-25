//
//  File.swift
//  resume_builder
//
//  Created by James Sobeck on 3/23/21.
//



import Foundation
import UIKit
import CoreData

class ResumeCategoryCell: UITableViewCell {
    @IBOutlet var title: UILabel!
    @IBOutlet var detailTitle: UILabel!
    @IBOutlet weak var catCell: UIView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var lineView: UIStackView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.backgroundColor = .systemGreen
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
    }
}



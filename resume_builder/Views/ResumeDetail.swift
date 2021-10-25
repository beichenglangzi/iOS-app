//
//  ResumeDetail.swift
//  resume_builder
//
//  Created by Ricky  Feig on 3/17/21.
//

import UIKit

class ResumeDetail: UITableViewCell {
    
        @IBOutlet weak var title: UILabel!
        @IBOutlet weak var dates: UILabel!
        @IBOutlet weak var desc: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

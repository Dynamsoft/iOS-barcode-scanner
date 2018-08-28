//
//  histroyDetailTableViewCell.swift
//  AwesomeBarcode
//
//  Created by Dynamsoft on 06/08/2018.
//  Copyright © 2018 Dynamsoft. All rights reserved.
//

import UIKit

class histroyDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var cellNum: UILabel!
    
    @IBOutlet weak var txtLabel: UILabel!
    
    @IBOutlet weak var formatLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

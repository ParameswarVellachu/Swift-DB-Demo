//
//  TblCustomCell.swift
//  Swift-DB-Demo
//
//  Created by Paramswar on 30/01/17.
//  Copyright © 2017 MTPL. All rights reserved.
//

import UIKit

class TblCustomCell: UITableViewCell {

    
    @IBOutlet var lblNotes: UILabel!
    @IBOutlet var btnEditAction: UIButton!
    @IBOutlet var btnDeleteAction: UIButton!
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

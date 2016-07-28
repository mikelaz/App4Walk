//
//  EventosTableViewCell.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 28/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class EventosTableViewCell: UITableViewCell {

    @IBOutlet weak var imagenEvento: UIImageView!
    
    @IBOutlet weak var nombreEvento: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

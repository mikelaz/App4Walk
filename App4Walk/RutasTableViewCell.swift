//
//  RutasTableViewCell.swift
//  App4Walk
//
//  Created by Mikel Aguirre on 21/7/16.
//  Copyright © 2016 Mikel Aguirre. All rights reserved.
//

import UIKit

class RutasTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var imagenCelda: UIImageView!
    @IBOutlet weak var nombreRuta: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  TableViewCell.swift
//  Todoey
//
//  Created by Yeoh Hui Qing on 28/11/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import UIKit
import SwipeCellKit

class TableViewCell: SwipeTableViewCell {

    var title: String = ""
    var count: Int = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.accessoryType = super.accessoryType
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configure(title: String, itemsCount: Int = 0) {
        self.title = title
        self.count = itemsCount
        
        self.titleLabel?.text = self.title
        if self.count > 0 {
            self.countLabel?.isHidden = false
            self.countLabel?.text = "\(self.count)"
        } else {
            self.countLabel?.isHidden = true
        }
    }
    
}

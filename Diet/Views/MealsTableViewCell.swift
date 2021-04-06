//
//  MealsTableViewCell.swift
//  Diet
//
//  Created by Sergey Sokolkin on 5.04.21.
//

import UIKit

class MealsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var caloriesView: UILabel!
    @IBOutlet weak var carbsView: UILabel!
    @IBOutlet weak var proteinView: UILabel!
    @IBOutlet weak var fatView: UILabel!
    @IBOutlet weak var titleView: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

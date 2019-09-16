//
//  MealTableViewCell.swift
//  WhatsForDinner
//
//  Created by Josh Quirey on 4/16/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import CoreData

class MealTableViewCell: UITableViewCell {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealFrequency: UILabel!
    @IBOutlet weak var mealCategories: UITextField!
    @IBOutlet weak var mealImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set (newFrame) {
            var frame = newFrame
            frame.origin.y += 8
            frame.size.height -= 2 * 5
            super.frame = frame
        }
    }
}

class PlanTableViewCell: UITableViewCell {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var planDate: UILabel!
    @IBOutlet weak var planMonth: UILabel!
    @IBOutlet weak var planDay: UILabel!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var prep: UILabel!
    @IBOutlet weak var cook: UILabel!
    @IBOutlet weak var mealCategories: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

class ReplaceTableViewCell: UITableViewCell {
    /////////////////////////////
    //Outlets
    /////////////////////////////
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var mealCategories: UITextField!
    @IBOutlet weak var prep: UILabel!
    @IBOutlet weak var cook: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
}

//
//  TodayViewController.swift
//  Today
//
//  Created by Josh Quirey on 10/11/19.
//  Copyright © 2019 jquirey. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
        
    @IBOutlet weak var planDate: UILabel!
    @IBOutlet weak var planMonth: UILabel!
    @IBOutlet weak var planDay: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
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
    @IBOutlet weak var mealCategories: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}

//
//  TimerCell.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit

class TimerCell: UITableViewCell {

    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    /*
     The method awakeFromNib() gets called on an object after it is loaded
     from an archive, which in this case is the storyboard file. By the time
     this method is called, all of the outlets have values and can be used.
     */
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        workoutLabel.adjustsFontForContentSizeCategory = true
        secondsLabel.adjustsFontForContentSizeCategory = true
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

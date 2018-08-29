//
//  TimerCell.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit

class TimerCell: UITableViewCell {

    // timer variable used to schedule the countdown
    var timer = Timer()
    
    // Keeps track of remaining seconds
    //var secondsRemaining = 1
    
    @IBAction func playCellButton(_ sender: UIButton) {
        
        //countdownLabel.text = String(secondsRemaining)
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateCellTimer), userInfo: nil, repeats: true)
        
    }
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var secondsText: UILabel!
    
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
        secondsText.adjustsFontForContentSizeCategory = true
    }
    
    @objc func updateCellTimer() {
        
        //var secondsRemaining = Int(secondsLabel.text!)!
        //secondsRemaining -= 1
        
        var seconds: Int = Int(secondsLabel.text!)!
        seconds -= 1
        secondsLabel.text = String(seconds)
        
        // why wont you work!!!
        //countdownLabel.text = String(seconds)
        
        if (seconds == 0) {
            timer.invalidate()
            //secondsLabel.text! = startingValue
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

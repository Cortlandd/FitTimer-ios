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
    
    @IBOutlet weak var playCellButton: UIButton!
    @IBAction func playCellButton(_ sender: UIButton?, semaphore: DispatchSemaphore) {
    
        let t = DispatchSource.makeTimerSource()
        
        t.schedule(deadline: .now(), repeating: .seconds(1))
        t.setEventHandler(handler: { [weak self] in
            self?.updateCellTimer(timer: t, semaphore: semaphore)
        })
        
        playCellButton.isHidden = true
        stopCellButton.isHidden = false
        
    }
    
    @IBOutlet weak var stopCellButton: UIButton!
    @IBAction func stopCellButton(_ sender: UIButton) {
        
        timer.invalidate()
        
        playCellButton.isHidden = false
        stopCellButton.isHidden = true
        
        countdownLabel.text = secondsLabel.text
        
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
    
    @objc func updateCellTimer(timer: DispatchSourceTimer, semaphore: DispatchSemaphore) {
        
        var secondsRemaining: Int = Int(countdownLabel.text!)!
        secondsRemaining -= 1
        countdownLabel.text = String(secondsRemaining)
        
        if (secondsRemaining == 0) {
            timer.cancel()
            semaphore.signal()
            
            countdownLabel.text = secondsLabel.text
            
            playCellButton.isHidden = false
            stopCellButton.isHidden = true
        }
        
    }
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}

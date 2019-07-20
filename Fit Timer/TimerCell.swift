//
//  TimerCell.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import AVFoundation

enum TimerCellState {
    case playing
    case stopped
    case paused
}

class TimerCell: UITableViewCell {

    @IBOutlet weak var _parentStackviewHeight: NSLayoutConstraint!
    // timer variable used to schedule the countdown
    var timer : DispatchSourceTimer?
    var cellSemaphore : DispatchSemaphore?
    
    var defaultHeight: CGFloat!
    
    var cellState: TimerCellState!
    
    //private var audioPlayer: AVAudioPlayer?
    @IBOutlet weak var _playbackOptionsView: UIStackView!
    
    @IBOutlet weak var playCellButton: UIButton!
    @IBAction func playCellButton(_ sender: UIButton?) {
    
        play(semaphore: cellSemaphore)
        
    }
    
    @IBOutlet weak var pauseCellButton: UIButton!
    @IBAction func pauseCellButton(_ sender: UIButton) {
        
        //cellState = .paused
        
        if pauseCellButton.titleLabel?.text == "Pause" {
            pauseCellButton.setTitle("Resume", for: .normal)
            
            timer?.suspend()
            
        }
        
        if pauseCellButton.titleLabel?.text == "Resume" {
            pauseCellButton.setTitle("Pause", for: .normal)
            
            timer?.resume()
            
            //cellState = .playing
        }
        
    }
    
    
    @IBAction func stopCellButton(_ sender: Any) {
        stopCell()
    }
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        workoutLabel.adjustsFontForContentSizeCategory = true
        secondsLabel.adjustsFontForContentSizeCategory = true
        
        
        // Settings for timer notification sound
//        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "bell", ofType: "wav")!)
//        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
//        try! AVAudioSession.sharedInstance().setActive(true)
//        try! audioPlayer = AVAudioPlayer(contentsOf: alertSound)
//        audioPlayer?.prepareToPlay()
        
    }
    
    func stopCell() {
        
        //cellState = .stopped
        
        timer?.cancel()
        cellSemaphore?.signal()
        
        _playbackOptionsView.isHidden = true
        playCellButton.isEnabled = true
        
        countdownLabel.text = secondsLabel.text
        
    }
    
    
    @objc func play(semaphore: DispatchSemaphore?) {
        
        //cellState = .playing
        
        timer?.cancel()
        semaphore?.signal()
        
        cellSemaphore = semaphore
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer?.setEventHandler(handler: { [weak self] in
            self!.updateCellTimer()
        })
        
        timer?.resume()
        
        _playbackOptionsView.isHidden = false
        
        // MARK: Figure out why this won't work on main thread
        DispatchQueue.main.async {
            self.playCellButton.isEnabled = false
        }
        
    }
    
    @objc func updateCellTimer() {
        
        var secondsRemaining: Int = Int(countdownLabel.text!)!
        secondsRemaining -= 1
        countdownLabel.text = String(secondsRemaining)
        
        if (secondsRemaining == 0) {
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //audioPlayer?.play()
            timer?.cancel()
            
            //cellState = .stopped
            cellSemaphore?.signal()
            
            countdownLabel.text = secondsLabel.text
            
            playCellButton.isEnabled = true
            
            _playbackOptionsView.isHidden = true
            
        }
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}


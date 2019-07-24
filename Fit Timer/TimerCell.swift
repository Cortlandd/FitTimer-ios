//
//  TimerCell.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

enum TimerCellState {
    case playing
    case stopped
    case paused
}

enum TimerAllCellState {
    case playingAll
    case stoppedAll
    case pausedAll
}

class TimerCell: UITableViewCell {
    
    // timer variable used to schedule the countdown
    var timer : DispatchSourceTimer?
    
    var speechSynthesizer: AVSpeechSynthesizer!
    
    var speechUtterance: AVSpeechUtterance!
    
    var defaultHeight: CGFloat!
    
    var cellState: TimerCellState = .playing {
        didSet {
            DispatchQueue.main.async {
                self.validateState()
            }
        }
    }
    
    //private var audioPlayer: AVAudioPlayer?

    @IBOutlet weak var _playbackOptionsView: UIStackView!
    
    @IBOutlet weak var playCellButton: UIButton!
    @IBAction func playCellButton(_ sender: UIButton?) {
        play()
    }
    
    @IBOutlet weak var pauseCellButton: UIButton!
    @IBAction func pauseCellButton(_ sender: UIButton) {
        
        if pauseCellButton.titleLabel?.text == "Pause" {
            pauseCellButton.setTitle("Resume", for: .normal)
            cellState = .paused
            timer?.suspend()
        }
        
        if pauseCellButton.titleLabel?.text == "Resume" {
            pauseCellButton.setTitle("Pause", for: .normal)
            cellState = .playing
            timer?.resume()
        }
    }
    
    @IBOutlet weak var stopCellButton: UIButton!
    @IBAction func stopCellButton(_ sender: Any) {
        stopCell()
    }
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    @IBOutlet weak var workoutImage: FLAnimatedImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        workoutLabel.adjustsFontForContentSizeCategory = true
        
        speechSynthesizer = AVSpeechSynthesizer()
        speechUtterance = AVSpeechUtterance(string: workoutLabel.text!)
        // Rate is to be adjusted for double words and single words
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // Is to be changed by country in settings and default to country
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-IE")
        
        /* Settings for timer notification sound
        let alertSound = URL(fileURLWithPath: Bundle.main.path(forResource: "bell", ofType: "wav")!)
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        try! audioPlayer = AVAudioPlayer(contentsOf: alertSound)
        audioPlayer?.prepareToPlay()
        */
    }
    
    func validateState() {
        switch cellState {
        case .playing:
            _playbackOptionsView.isHidden = false
            workoutImage.isHidden = false
            playCellButton.isEnabled = false
        case .paused:
            _playbackOptionsView.isHidden = false
            workoutImage.isHidden = false
        case .stopped:
            _playbackOptionsView.isHidden = true
            workoutImage.isHidden = true
            countdownLabel.text = secondsLabel.text
            playCellButton.isEnabled = true
        default:
            break
        }
    }
    
    func stopCell() {
        
        // Capture current state before stopped state to decide to timer.resume() or not
        let prevState = cellState
        
        if cellState == .stopped {
            return
        }
        cellState = .stopped
        
        timer?.setEventHandler {}
        timer?.cancel()
        
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        if prevState == .paused {
            timer?.resume()
        } else {
            return
        }
    }
    
    /* Handle Single Cell */
    @objc func play() {
        
        speechUtterance = AVSpeechUtterance(string: workoutLabel.text!)
        speechSynthesizer.speak(speechUtterance)
        
        cellState = .playing
        
        //timer?.cancel() // This here probably shouldn't happen.
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer?.setEventHandler(handler: { [weak self] in
            self!.updateCellTimer()
        })
        
        timer?.resume()
        
    }
    
    @objc func updateCellTimer() {
        
        var secondsRemaining: Int = Int(countdownLabel.text!)!
        secondsRemaining -= 1
        countdownLabel.text = String(secondsRemaining)
        
        if (secondsRemaining == 0) {
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //audioPlayer?.play()
            
            timer?.cancel()
            
            cellState = .stopped
            
        }
        
    }
    
    /* Handle All Cell */
    @objc func updateAllCellTimer(semaphore: DispatchSemaphore?) {
        
        var secondsRemaining: Int = Int(countdownLabel.text!)!
        secondsRemaining -= 1
        countdownLabel.text = String(secondsRemaining)
        
        if (secondsRemaining == 0) {
            //AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
            //audioPlayer?.play()
            
            workoutImage.isHidden = true
            
            timer?.cancel()
            
            semaphore?.signal()
            
            pauseCellButton.isEnabled = false
            
        }
        
    }
    
    @objc func playAll(semaphore: DispatchSemaphore) {
        
        cellState = .playing
        
        speechUtterance = AVSpeechUtterance(string: workoutLabel.text!)
        speechSynthesizer.speak(speechUtterance)
        
        //timer?.cancel() // This here probably shouldn't happen.
        
        timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer?.schedule(deadline: .now(), repeating: .seconds(1))
        
        timer?.setEventHandler(handler: { [weak self] in
            self!.updateAllCellTimer(semaphore: semaphore)
        })
        
        timer?.resume()
        
        // MARK: Figure out why this won't work on main thread
        DispatchQueue.main.async {
            self.playCellButton.isEnabled = false
            self.stopCellButton.isHidden = true
        }
        
    }
    
    /*
     A hack to stop all cells from timerviewcontroller
     */
    func stopAllCell() {
        
        // Capture current state before stopped state to decide to timer.resume() or not
        let prevState = cellState
        
        if cellState == .stopped {
            return
        }
        cellState = .stopped
        
        timer?.cancel()
        
        /*
         If the timer is suspended, calling cancel without resuming
         triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
         */
        if prevState == .paused {
            timer?.resume()
        } else {
            return
        }
        
    }
    
    // To be called after 'Stop All' is tapped
    func resetAllCells(semaphore: DispatchSemaphore?) {
        
        timer?.cancel()
        
        semaphore?.suspend()
        
        playCellButton.isEnabled = true
        stopCellButton.isHidden = false
        _playbackOptionsView.isHidden = true
        workoutImage.isHidden = true
        
        // MARK: decide is timer?.resume() needs to go here
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}


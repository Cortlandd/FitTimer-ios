//
//  FullWorkoutCell.swift
//  ExerciseDemo
//
//  Created by Cortland Walker on 8/21/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

enum FullWorkoutCellState {
    case playingAll
    case stoppedAll
    case finishedAll
}

enum CellState {
    case collapsed
    case expanded
}

protocol FullWorkoutCellDelegate: AnyObject {
    func workoutCellDidPressedPlay(_ exerciseCell: FullWorkoutCell, index: Int)
    func workoutCellDidPressedStop(_ exerciseCell: FullWorkoutCell, index: Int)
    func workoutDidFinish(_ workoutCell: FullWorkoutCell, index: Int)
}

class FullWorkoutCell: UITableViewCell {
    
    /********************* UI Components *******************/
    
    @IBOutlet var countdownTimer: SRCountdownTimer!
    @IBOutlet var backView: UIView!
    @IBOutlet var bottomView: UIView!
    @IBOutlet weak var workoutLabel: UILabel!
    @IBOutlet weak var workoutImage: FLAnimatedImageView!
    @IBOutlet weak var btnPlayWidth: NSLayoutConstraint!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnPause: UIButton!
    @IBOutlet var btnStop: UIButton!
    
    @IBAction func _btnPlay(_ sender: Any) {
        play()
    }
    @IBAction func _btnStop(_ sender: Any) {
        stopCell()
    }
    @IBAction func _btnPause(_ sender: Any) {
        pause()
    }
    
    /********************* Variables *******************/
    
    var timer: DispatchSourceTimer?
    var speechSynthesizer: AVSpeechSynthesizer!
    var speechUtterance: AVSpeechUtterance!
    var semaphore: DispatchSemaphore?
    var finishedSemaphore: DispatchSemaphore?
    var state: CellState = .collapsed
    var index: Int = 0
    weak var delegate: FullWorkoutCellDelegate?
    var currentCount: Int! // Set from configure() in Timerviewcontroller
    var fullWorkoutCellState: FullWorkoutCellState = .stoppedAll {
        didSet {
            DispatchQueue.main.async {
                self.validateState()
            }
        }
    }
    
    /********************* Functions *******************/
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backView.layer.masksToBounds = false
        backView.layer.cornerRadius = 20.0
        backView.layer.shadowColor = UIColor.lightGray.cgColor
        backView.layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        backView.layer.shadowRadius = 5.0
        backView.layer.shadowOpacity = 0.7
        
        speechSynthesizer = AVSpeechSynthesizer()
        speechUtterance = AVSpeechUtterance(string: workoutLabel.text!)
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate // Rate is to be adjusted for double words and single words
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-IE") // Is to be changed by country in settings and default to country
        countdownTimer.delegate = self
        countdownTimer.timerFinishingText = countdownTimer.counterLabel.text
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        state = .collapsed
        self.bottomView.alpha = 0
        self.btnPlay.alpha = 1
        self.btnPlayWidth.constant = 80
        countdownTimer.end()
    }
    
    /********************* Handling for a single cell ***********************/
    
    func stopCell() {
        countdownTimer.end()
    }
    
    func play() {
        state = .expanded
        reloadUIAnimated()
        countdownTimer.start(beginingValue: currentCount)
        delegate?.workoutCellDidPressedPlay(self, index: index)
    }
    
    func pause() {
        if btnPause.titleLabel?.text == "PAUSE" {
            btnPause.setTitle("RESUME", for: .normal)
            countdownTimer?.pause()
        }
        if btnPause.titleLabel?.text == "RESUME" {
            btnPause.setTitle("PAUSE", for: .normal)
            countdownTimer?.resume()
        }
    }
    
    /********************* Handling for a All Cells ***********************/
    
    func playAll() {
        
        //speechUtterance = AVSpeechUtterance(string: workoutLabel.text!)
        //speechSynthesizer.speak(speechUtterance)
        
        fullWorkoutCellState = .playingAll
        
        play()
    }
    
    func stopAll() {
        
        fullWorkoutCellState = .stoppedAll
        
        resetTimer()
        stopWorkout()
    }
    
    /********************* Helpers ***********************/
    
    func reloadUI() {
        let expanded = (state == .expanded)
        self.bottomView.alpha = expanded ? 1 : 0
        self.btnPlay.alpha = expanded ? 0 : 1
        btnPlayWidth.constant = expanded ? 0 : 80
    }
    
    func reloadUIAnimated() {
        let expanded = (state == .expanded)
        self.btnPlayWidth.constant = expanded ? 0 : 80
        
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.layoutIfNeeded()
            self.bottomView.alpha = expanded ? 1 : 0
            self.btnPlay.alpha = expanded ? 0 : 1
        })
    }
    
    func resetTimer() {        
        countdownTimer.elapsedTime = 0
        countdownTimer.setNeedsDisplay()
    }
    
    func stopWorkout() {
        state = .collapsed
        reloadUIAnimated()
        delegate?.workoutCellDidPressedStop(self, index: index)
    }
    
    func validateState() {
        switch fullWorkoutCellState {
        case .playingAll:
            countdownTimer.timerFinishingText = "0"
        case .stoppedAll:
            countdownTimer.timerFinishingText = countdownTimer.counterLabel.text
        case .finishedAll:
            print("")
        }
    }
    
}

extension FullWorkoutCell: SRCountdownTimerDelegate {
    
    func timerDidUpdateCounterValue(newValue: Int) {
        
    }
    
    func timerDidStart() {
        let defaults = UserDefaults.standard
        
        defaults.set(true, forKey: "workoutStarted")
        
        defaults.set(workoutLabel.text!, forKey: "workoutName")
        defaults.set("\(countdownTimer.counterLabel.text!) Second Workout.", forKey: "workoutTime")
        // Get remaining seconds
        //defaults.set(Any?, forKey: "workoutRemainingTime")
    }
    
    func timerDidPause() {
        
    }
    
    func timerDidResume() {
        
    }
    
    func timerDidEnd() {
        if btnPause.titleLabel?.text == "RESUME" {
            btnPause.setTitle("PAUSE", for: .normal)
        }
        if fullWorkoutCellState == .playingAll {
            semaphore?.signal()
            delegate?.workoutDidFinish(self, index: index)
        } else {
            // TODO MARK: May need to investigate
            let defaults = UserDefaults.standard
            defaults.set(false, forKey: "workoutStarted")
            
            resetTimer()
            stopWorkout()
        }
    }
}

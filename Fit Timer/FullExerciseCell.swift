//
//  FullExerciseCell.swift
//  ExerciseDemo
//
//  Created by Vishv Infotech on 21/08/19.
//  Copyright © 2019 Vishv Infotech. All rights reserved.
//

import UIKit
import AVFoundation
import FLAnimatedImage

enum FullExerciseCellState {
    case playingAll
    case stoppedAll
}

enum CellState {
    case collapsed
    case expanded
}

protocol FullExerciseCellDelegate: AnyObject {
    func exerciseCellDidPressedPlay(_ exerciseCell: FullExerciseCell, index: Int)
    func exerciseCellDidPressedStop(_ exerciseCell: FullExerciseCell, index: Int)
}

class FullExerciseCell: UITableViewCell {
    
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
    var state: CellState = .collapsed
    var index: Int = 0
    weak var delegate: FullExerciseCellDelegate?
    var currentCount: Int! // Set from configure() in Timerviewcontroller
    var fullExerciseCellState: FullExerciseCellState = .stoppedAll {
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
        delegate?.exerciseCellDidPressedPlay(self, index: index)
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
        
        fullExerciseCellState = .playingAll
        
        play()
    }
    
    func stopAll() {
        
        fullExerciseCellState = .stoppedAll
        
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
        delegate?.exerciseCellDidPressedStop(self, index: index)
    }
    
    func validateState() {
        switch fullExerciseCellState {
        case .playingAll:
            countdownTimer.timerFinishingText = "0"
        case .stoppedAll:
            countdownTimer.timerFinishingText = countdownTimer.counterLabel.text
        default:
            break
        }
    }
    
}

extension FullExerciseCell: SRCountdownTimerDelegate {
    
    func timerDidUpdateCounterValue(newValue: Int) {
        
    }
    
    func timerDidStart() {
        
    }
    
    func timerDidPause() {
        if fullExerciseCellState == .playingAll {
            print("")
        } else {
            print("")
        }
    }
    
    func timerDidResume() {
        if fullExerciseCellState == .playingAll {
            print("")
        } else {
            print("")
        }
    }
    
    func timerDidEnd() {
        if fullExerciseCellState == .playingAll {
            semaphore?.signal()
        } else {
            resetTimer()
            stopWorkout()
        }
    }
}

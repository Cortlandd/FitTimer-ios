//
//  PopupViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/6/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation

class ShowWorkoutViewController: UIViewController {
    
    var timerViewController: TimerViewController?
    
    var speechSynthesizer: AVSpeechSynthesizer!
    
    var speechUtterance: AVSpeechUtterance!
    
    var workout: Workout?
    
    var controllerTitle = "Add New Workout"
    
    var managedObjectContext: NSManagedObjectContext?
    
    var selectedPickerRow: Int!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    @IBOutlet weak var newWorkoutField: UITextField!
    @IBOutlet weak var soundSwitch: UISwitch!
        
    @IBAction func testSpeechButton(_ sender: Any) {
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        guard let managedObjectContext = managedObjectContext else { return }
        
        selectedPickerRow = pickerView.selectedRow(inComponent: 0)
        
        if workout == nil {
            
            // Create Workout
            let newWorkout = Workout(context: managedObjectContext)
            
            newWorkout.createdAt = Date().timeIntervalSince1970
            
            workout = newWorkout
            
        }
        
        if let workout = workout {
            // Configure Workout
            workout.workout = newWorkoutField.text!
            workout.seconds = Int16(selectedPickerRow)
        }
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = controllerTitle
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if let workout = workout {
            newWorkoutField.text = workout.workout
            pickerView.selectRow(selectedPickerRow, inComponent: 0, animated: true)
            
        }
        
        // Listen for text changes
        newWorkoutField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        
        speechSynthesizer = AVSpeechSynthesizer()
        speechUtterance = AVSpeechUtterance(string: newWorkoutField.text ?? "Enter A Workout")
        // Rate is to be adjusted for double words and single words
        speechUtterance.rate = AVSpeechUtteranceDefaultSpeechRate
        // Is to be changed by country in settings and default to country
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-IE")
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        speechUtterance = AVSpeechUtterance(string: textField.text!)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension ShowWorkoutViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 60
        } else {
            return 1
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row)"
        } else {
            return "sec"
        }
    }
    
    
}

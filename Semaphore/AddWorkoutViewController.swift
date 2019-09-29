//
//  AddWorkoutViewController.swift
//  Fit Timer
//
//  Created by Cortland Walker on 8/23/19.
//  Copyright © 2019 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import FLAnimatedImage
import UserNotifications

class AddWorkoutViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    /************* Variables ***************/
    var WorkoutViewController: WorkoutViewController?
    var speechSynthesizer: AVSpeechSynthesizer?
    var speechUtterance: AVSpeechUtterance?
    var controllerTitle = "Add New Workout"
    var managedObjectContext: NSManagedObjectContext?
    var selectedPickerRow: Int!
    var hours: Int = 0
    var minutes: Int = 0
    var seconds: Int = 0
    
    /************* UI Components ***************/
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var workoutImage: FLAnimatedImageView!
    @IBOutlet weak var newWorkoutField: UITextField!
    @IBOutlet weak var soundSwitch: UISwitch!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBAction func testSpeechButton(_ sender: Any) {
        speechSynthesizer?.speak(speechUtterance!)
    }
    
    @IBAction func saveButton(_ sender: Any) {
        
        guard let managedObjectContext = managedObjectContext else { return }
        
        // Create Workout
        let workout = Workout(context: managedObjectContext)
        
        // Configure Workout
        workout.createdAt = Date().timeIntervalSince1970
        workout.workout = newWorkoutField.text!
        workout.hours = Int16(hours)
        workout.minutes = Int16(minutes)
        workout.seconds = Int16(seconds)
        let nilData: Data? = nil // A hack so the below won't fucking crash if an image isn't selected
        workout.workoutImage = workoutImage.animatedImage?.data ?? nilData
        
        do {
            try managedObjectContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
        
        _ = navigationController?.popViewController(animated: true)
    }
    
    /************* Overrides ***************/
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Listen for text changes
        newWorkoutField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: UIControl.Event.editingChanged)
        newWorkoutField.delegate = self

        speechSynthesizer = AVSpeechSynthesizer()
        speechUtterance = AVSpeechUtterance(string: newWorkoutField.text ?? "Enter A Workout")
        // Rate is to be adjusted for double words and single words
        speechUtterance?.rate = AVSpeechUtteranceDefaultSpeechRate
        // Is to be changed by country in settings and default to country
        speechUtterance?.voice = AVSpeechSynthesisVoice(language: "en-IE")
        
        // Request permission to get in-app notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { (didAllow, error) in
        }
        
        let tapOutsideGesture = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard(_:)))
        self.view.addGestureRecognizer(tapOutsideGesture)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "selectGiphyImage":
            let giphyController = (segue.destination as? UINavigationController)?.viewControllers.first as? SwiftyGiphyViewController
            giphyController?.delegate = self
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }
    
    /************* Helper Functions ***************/
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        speechUtterance = AVSpeechUtterance(string: textField.text!)
        
        if textField.text == "" {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
        
        if textField.text == "" && pickerView.selectedRow(inComponent: 0) == 0 && pickerView.selectedRow(inComponent: 2) == 0 && pickerView.selectedRow(inComponent: 4) == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
        
        if pickerView.selectedRow(inComponent: 0) == 0 && pickerView.selectedRow(inComponent: 2) == 0 && pickerView.selectedRow(inComponent: 4) == 0 {
            saveButton.isEnabled = false
        } else {
            saveButton.isEnabled = true
        }
        
    }

}

/************* Extensions ***************/
extension AddWorkoutViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width / 7
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 6
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // if 0 is selected disable save button.
        switch component {
        case 0:
            hours = row
        case 2:
            minutes = row
        case 4:
            seconds = row
        default:
            break;
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0:
            return 24
        case 1,3,5:
            return 1
        case 2,4:
            return 60
        default:
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0:
            return (0...9).contains(row) ? "0\(row)" : "\(row)"
        case 1:
            return "hr"
        case 2:
            return (0...9).contains(row) ? "0\(row)" : "\(row)"
        case 3:
            return "min"
        case 4:
            return (0...9).contains(row) ? "0\(row)" : "\(row)"
        case 5:
            return "sec"
        default:
            return ""
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        newWorkoutField.resignFirstResponder()
    }
    
}

extension AddWorkoutViewController: SwiftyGiphyViewControllerDelegate {
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        if let gifDownSized = item.downsizedImage {
            
            // Activity/Loading spinner
            workoutImage?.sd_setShowActivityIndicatorView(true)
            workoutImage?.sd_setIndicatorStyle(.gray)
            
            workoutImage?.sd_setImage(with: gifDownSized.url)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

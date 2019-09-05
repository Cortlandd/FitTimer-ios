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
    
    private let persistentContainer = NSPersistentContainer(name: "Workouts")

    /************* Variables ***************/
    var WorkoutViewController: WorkoutViewController?
    var speechSynthesizer: AVSpeechSynthesizer?
    var speechUtterance: AVSpeechUtterance?
    var controllerTitle = "Add New Workout"
    var managedObjectContext: NSManagedObjectContext?
    var selectedPickerRow: Int!
    
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
        
        let defaults = UserDefaults.standard
        
        // Selected row in picker
        selectedPickerRow = pickerView.selectedRow(inComponent: 0)
        
        // Create Workout
        let workout = Workout(context: persistentContainer.viewContext)
        
        // Configure Workout
        workout.createdAt = Date().timeIntervalSince1970
        workout.workout = newWorkoutField.text!
        workout.seconds = Int16(selectedPickerRow)
        let nilData: Data? = nil // A hack so the below won't fucking crash if an image isn't selected
        workout.workoutImage = workoutImage.animatedImage?.data ?? nilData
        
        do {
            try persistentContainer.viewContext.save()
            defaults.set(true, forKey: "addedNewWorkout")
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
        
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            }
        }
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
        
        validateWorkoutText(textField)
    }
    
    func validateWorkoutText(_ textField: UITextField) {
        if textField.text == "" {
            saveButton.isEnabled = false
        }
        if pickerView.selectedRow(inComponent: 0) == 0 {
            saveButton.isEnabled = false
        }
        if textField.text == "" && pickerView.selectedRow(inComponent: 0) == 0 {
            saveButton.isEnabled = false
        }
        if textField.text != "" &&  pickerView.selectedRow(inComponent: 0) == 0 {
            saveButton.isEnabled = false
        }
        if textField.text != "" && pickerView.selectedRow(inComponent: 0) != 0 {
            saveButton.isEnabled = true
        }
    }

}

/************* Extensions ***************/
extension AddWorkoutViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50.0
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // if 0 is selected disable save button.
        if component == 0 {
            if row == 0 {
                saveButton.isEnabled = false
            }
        }
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

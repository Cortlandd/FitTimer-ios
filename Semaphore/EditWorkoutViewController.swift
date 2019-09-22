//
//  EditWorkoutViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/6/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData
import AVFoundation
import FLAnimatedImage

class EditWorkoutViewController: UIViewController, UINavigationControllerDelegate {
    
    var WorkoutViewController: WorkoutViewController?
    var speechSynthesizer: AVSpeechSynthesizer!
    var speechUtterance: AVSpeechUtterance!
    var workout: Workout?
    var managedObjectContext: NSManagedObjectContext?
    var selectedPickerRow: Int!
    var hours = 0
    var minutes = 0
    var seconds = 0
    
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var _workoutImage: FLAnimatedImageView!
    @IBOutlet weak var newWorkoutField: UITextField!
    @IBOutlet weak var soundSwitch: UISwitch!
        
    @IBAction func testSpeechButton(_ sender: Any) {
        speechSynthesizer.speak(speechUtterance)
    }
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBAction func saveButton(_ sender: Any) {
        
        guard let managedObjectContext = managedObjectContext else { return }
        
        hours = pickerView.selectedRow(inComponent: 0)
        minutes = pickerView.selectedRow(inComponent: 2)
        seconds = pickerView.selectedRow(inComponent: 4)
        
        if workout == nil {
            
            // Create Workout
            let newWorkout = Workout(context: managedObjectContext)
            
            newWorkout.createdAt = Date().timeIntervalSince1970
            
            workout = newWorkout
            
        }
        
        if let workout = workout {
            // Configure Workout
            workout.workout = newWorkoutField.text!
            workout.hours = Int16(hours)
            workout.minutes = Int16(minutes)
            workout.seconds = Int16(seconds)
            let nilData: Data? = nil // A hack so the below won't fucking crash. smh
            workout.workoutImage = _workoutImage.animatedImage?.data ?? nilData
        }
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
//    @IBAction func _cameraRollImage(_ sender: Any) {
//        
//        let imagePicker = UIImagePickerController()
//        
//        // Upload image using photo library
//        imagePicker.sourceType = .photoLibrary
//        imagePicker.delegate = self
//        
//        // Place imagepicker on the screen
//        present(imagePicker, animated: true, completion: nil)
//
//        
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        if let workout = workout {
            newWorkoutField.text = workout.workout
            pickerView.selectRow(Int(workout.hours), inComponent: 0, animated: true) // Update Hours
            pickerView.selectRow(Int(workout.minutes), inComponent: 2, animated: true) // Update Minutes
            pickerView.selectRow(Int(workout.seconds), inComponent: 4, animated: true) // Update Seconds
            let image: FLAnimatedImage? = FLAnimatedImage.init(animatedGIFData: workout.workoutImage)
            _workoutImage?.animatedImage = image
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "selectGiphyImage":
            let giphyController = (segue.destination as? UINavigationController)?.viewControllers.first as? SwiftyGiphyViewController
            giphyController?.delegate = self
        default:
            preconditionFailure("Unexpected Segue Identifier")
        }
    }
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension EditWorkoutViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.width / 8
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
}

extension EditWorkoutViewController: SwiftyGiphyViewControllerDelegate {
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        if let gifDownSized = item.downsizedImage {
            
            // Activity/Loading spinner
            _workoutImage?.sd_setShowActivityIndicatorView(true)
            _workoutImage?.sd_setIndicatorStyle(.gray)
            
            _workoutImage?.sd_setImage(with: gifDownSized.url)
            
            dismiss(animated: true, completion: nil)
        }
    }
    
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}

//extension EditWorkoutViewController: UIImagePickerControllerDelegate {
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//
//        // Get the picked image
//        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
//
//        _workoutImage.image = image
//
//        // Take image picker off the screen you must call this dismiss method
//        dismiss(animated: true, completion: nil)
//
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//}

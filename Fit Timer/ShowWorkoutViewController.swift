//
//  PopupViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/6/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData

class ShowWorkoutViewController: UIViewController {
    
    var timerViewController: TimerViewController?
    
    var workout: Workout?
    
    var controllerTitle = "Add New Workout"
    
    var managedObjectContext: NSManagedObjectContext?
    
    @IBOutlet weak var newWorkoutField: UITextField!
    @IBOutlet weak var secondsField: UITextField!
    @IBOutlet weak var soundSwitch: UISwitch!
    
    @IBAction func saveButton(_ sender: Any) {
        
        guard let managedObjectContext = managedObjectContext else { return }
        
        if workout == nil {
            
            // Create Workout
            let newWorkout = Workout(context: managedObjectContext)
            
            newWorkout.createdAt = Date().timeIntervalSince1970
            
            workout = newWorkout
            
        }
        
        if let workout = workout {
            // Configure Workout
            workout.workout = newWorkoutField.text!
            workout.seconds = Int16(secondsField.text!)!
        }
        
        _ = navigationController?.popViewController(animated: true)
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        secondsField.keyboardType = UIKeyboardType.numberPad
        
        self.title = controllerTitle
        
        if let workout = workout {
            newWorkoutField.text = workout.workout
            secondsField.text = workout.seconds.description
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  PopupViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/6/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController {
    
    var timerStore: TimerStore!
    
    var timerViewController: TimerViewController?
    
    @IBOutlet weak var newWorkoutField: UITextField!
    @IBOutlet weak var secondsField: UITextField!
    
    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnNewFitTimer(_ sender: Any) {
        
        let workoutField = newWorkoutField.text!
        let secondField = secondsField.text!
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

//
//  DetailViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/21/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController, UITextFieldDelegate {

    
    var timerModel: TimerModel!
    
    @IBOutlet var secondsDetailField: UITextField!
    @IBOutlet var workoutDetailField: UITextField!
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        workoutDetailField.text = timerModel.workout
        secondsDetailField.text = timerModel.secondsPick
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the keyboard
        view.endEditing(true)
        
        // Save changes to timer
        timerModel.workout = workoutDetailField.text ?? ""
        timerModel.secondsPick = secondsDetailField.text ?? ""
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    

}

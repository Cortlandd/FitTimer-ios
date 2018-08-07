//
//  PopupViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/6/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit

class PopupViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    

    @IBAction func closePopup(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var secondsPicker: UIPickerView!
    var pickerData: [String] = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.secondsPicker.delegate = self
        self.secondsPicker.dataSource = self
        
        pickerData = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // The number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    // The number of rows of data
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    // The data to return for the row and component (column) that's being passed in
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row]
    }

}

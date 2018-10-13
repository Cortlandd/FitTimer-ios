//
//  DetailViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/21/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import Photos
import SwiftyGiphy

class DetailViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, SwiftyGiphyViewControllerDelegate  {
    
    var timerModel: TimerModel!
    var imageStore: ImageStore!
    
    @IBOutlet var detailImageView: UIImageView!
    @IBOutlet var secondsDetailField: UITextField!
    @IBOutlet var workoutDetailField: UITextField!
    @IBOutlet weak var detailSwitch: UISwitch!
    
    @IBAction func useGiphy(_ sender: UIBarButtonItem) {
        // Open Navigation controller containing SwiftGiphyViewController
        performSegue(withIdentifier: "gifSelectorSegue", sender: self)
    }
    
    @IBAction func takePicture(_ sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        
        // If the device has a camera, take a picture; otherwise, just pick from photo library
        //if UIImagePickerController.isSourceTypeAvailable(.camera) {
        //    imagePicker.sourceType = .camera
        //} else {
        //    imagePicker.sourceType = .photoLibrary
        //}
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        
        // Place imagepicker on the screen
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func backgroundTapped(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func giphyControllerDidSelectGif(controller: SwiftyGiphyViewController, item: GiphyItem) {
        
        if let gifDownSized = item.downsizedImage {
            detailImageView.sd_setImage(with: gifDownSized.url)
            
            /* I NEED TO CACHE THIS GIF */
            
            // Store the image in the ImageStore for the item's key
            imageStore.setImage(img, forKey: timerModel.imgKey)
        }
        
        print("TAPPED AN IMAGE")
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func giphyControllerDidCancel(controller: SwiftyGiphyViewController) {
        print("hello")
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        
        // Get the picked image
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Store the image in the ImageStore for the item's key
        imageStore.setImage(image, forKey: timerModel.imgKey)
        
        // Put the image to the screen in the detailImageView
        detailImageView.image = image
        
        // Take image picker off the screen you must call this dismiss method
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "gifSelectorSegue"?:
            
            let del = (segue.destination as? UINavigationController)?.viewControllers.first as? SwiftyGiphyViewController
            del?.delegate = self
            
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        workoutDetailField.text = timerModel.workout
        secondsDetailField.text = timerModel.secondsPick
        detailSwitch.isOn = timerModel.soundEnabled
        
        // Get the item key
        let key = timerModel.imgKey
        
        // If there is an associated image with the item display it on the image view
        let imageToDisplay = imageStore.image(forKey: key)
        detailImageView.image = imageToDisplay
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Close the keyboard
        view.endEditing(true)
        
        // Save changes to timer
        timerModel.workout = workoutDetailField.text ?? ""
        timerModel.secondsPick = secondsDetailField.text ?? ""
        timerModel.soundEnabled = detailSwitch.isOn
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


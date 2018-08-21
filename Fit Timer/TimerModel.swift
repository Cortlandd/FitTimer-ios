//
//  TimerModel.swift
//  Fit Timer
//
//  Created by User 1 on 8/8/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import Foundation
import UIKit

class TimerModel: NSObject {
    
    var workout: String
    var secondsPick: String
    
    init(workout: String, secondsPick: String) {
        self.workout = workout
        self.secondsPick = secondsPick
    }
    
    convenience init(random: Bool = false) {
        if random {
            let workouts = ["Mountain Climbers", "Pull Ups", "Leg Lifts"]
            let secondsPicks = ["30", "30", "30"]
            
            var idx = arc4random_uniform(UInt32(workouts.count))
            let randomWorkout = workouts[Int(idx)]
            
            idx = arc4random_uniform(UInt32(secondsPicks.count))
            let randomSeconds = secondsPicks[Int(idx)]
            
            self.init(workout: randomWorkout, secondsPick: randomSeconds)
        } else {
            self.init(workout: "", secondsPick: "")
        }
    }
    
}

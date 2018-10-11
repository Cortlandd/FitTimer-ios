//
//  TimerStore.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

/*
 At this point you may be wondering why timerStore was set externally on the ViewController. Why didn’t the ViewController instance itself just create an instance of the store? The reason for this approach is based on a fairly complex topic called the dependency inversion principle.
 The essential goal of this principle is to decouple objects in an application by inverting certain dependencies between them. This results in more robust and maintainable code.
 The dependency inversion principle states that:
 1. High-level objects should not depend on low-level objects. Both should depend on abstractions. 2. Abstractions should not depend on details. Details should depend on abstractions.
 The abstraction required by the dependency inversion principle in Homepwner is the concept of a “store.” A store is a lower-level object that retrieves and saves Item instances through details that are only known to that class.
 
*/

import UIKit

class TimerStore {
    
    var allTimers = [TimerModel]()
    
    @discardableResult func customTimer(workout: String, seconds: String, soundEnabled: Bool) -> TimerModel {
        let newtimer = TimerModel(workout: workout, secondsPick: seconds, soundEnabled: soundEnabled)
        
        allTimers.append(newtimer)
        
        return newtimer
    }
    
    @discardableResult func createTimer() -> TimerModel {
        let newTimer = TimerModel(random: true)
        
        allTimers.append(newTimer)
        
        return newTimer
    }
    
    func removeTimer(_ timerModel: TimerModel) {
        if let index = allTimers.index(of: timerModel) {
            allTimers.remove(at: index)
        }
    }
    
    func moveTimer(from fromIndex: Int, to toIndex: Int) {
        if fromIndex == toIndex {
            return
        }
        
        // Get reference to object being moved so I can insert it
        let movedTimer = allTimers[fromIndex]
        
        // Remove timer from array
        allTimers.remove(at: fromIndex)
        
        // Insert timer to new location
        allTimers.insert(movedTimer, at: toIndex)
    }
    
    
}

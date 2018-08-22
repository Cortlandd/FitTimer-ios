//
//  TimerViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit

class TimerViewController: UITableViewController {
    
    @IBAction func addNewTimer(_ sender: UIBarButtonItem) {
        // Create a new item and add it to the store
        let newTimer = timerStore.createTimer()
        // Figure out where that item is in the array
        if let index = timerStore.allTimers.index(of: newTimer) {
            let indexPath = IndexPath(row: index, section: 0)
            // Insert this new row into the table
            tableView.insertRows(at: [indexPath], with: .automatic)
        }
    }
    
    var timerStore: TimerStore!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        navigationItem.leftBarButtonItem = editButtonItem
    }
    
    // Once the backbutton is pressed on detail page and this screen appears. Do:
    override func viewDidAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // If the triggered segue is the "showItem" segue
        switch segue.identifier {
        case "showTimer"?:
            // Figure out which row was just tapped
            if let row = tableView.indexPathForSelectedRow?.row {
                // Get the item associated with this row and pass it along
                let timer = timerStore.allTimers[row]
                let detailViewController = segue.destination as! DetailViewController
                detailViewController.timerModel = timer
            }
        case "showAddPopup"?:
            if (segue.destination.isKind(of: PopupViewController.self)) {
                (segue.destination as! PopupViewController).timerStore = timerStore
            }
        default:
            preconditionFailure("Unexpected segue identifier.")
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return timerStore.allTimers.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        
        let timers = timerStore.allTimers[indexPath.row]
        
        cell.workoutLabel?.text = timers.workout
        cell.secondsLabel?.text = timers.secondsPick
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // if the table is asked to delete
        if editingStyle == .delete {
            
            // Fetch the specific row in table
            let item = timerStore.allTimers[indexPath.row]
            
            // Remove fetched row
            timerStore.removeTimer(item)
            
            // Remove row in table
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // update the model
        timerStore.moveTimer(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
}

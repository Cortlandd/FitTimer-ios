//
//  TimerViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData

class TimerViewController: UITableViewController {
    
    private let persistentContainer = NSPersistentContainer(name: "Workouts")
    
    @IBOutlet var _noWorkoutsMessage: UIView!
    
    fileprivate lazy var fetchResultsController: NSFetchedResultsController<Workout> = {
        // Create fetch Request
        let fetchRequest: NSFetchRequest<Workout> = Workout.fetchRequest()
        
        // Configure Fetch Request
        // MARK: Find a way to get position when created
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: true)]
        
        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
        
    }()
    
    @IBOutlet weak var _playAllButton: UIButton!
    @IBAction func _playAllButton(_ sender: UIButton) {
        
        let cells = self.tableView.visibleCells as! [TimerCell]
        
        let semaphore = DispatchSemaphore(value: 1)
        
        if _playAllButton.titleLabel?.text == "Play All" {
            
            _addNewTimer.isEnabled = false
            
            _playAllButton.setTitle("Stop All", for: .normal)
            
            // Prevent user from tapping Play on a cell, then tapping Play All
//            for cell in cells {
//                if cell.cellState == .playing {
//                    cell.stopCell()
//                    cell.resetAllCells(semaphore: semaphore)
//                }
//            }
            
            DispatchQueue.global().async {
                for cell in cells {
                    semaphore.wait()
                    cell.playAll(semaphore: semaphore)
                }
            }    
        }
        
        if _playAllButton.titleLabel?.text == "Stop All" {
            
            for cell in cells {
                cell.resetAllCells(semaphore: semaphore)
            }
            
            _playAllButton.setTitle("Play All", for: .normal)
            _addNewTimer.isEnabled = true
        }
        
    }
    
    @IBOutlet weak var _addNewTimer: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 90
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.backgroundView = _noWorkoutsMessage
        
        /*
         The loadPersistentStores(completionHandler:) method asynchronously loads the persistent store(s) and adds it to the persistent store coordinator.
         */
        persistentContainer.loadPersistentStores { (persistentStoreDescription, error) in
            if let error = error {
                print("Unable to Load Persistent Store")
                print("\(error), \(error.localizedDescription)")
                
            } else {
                self.setupView()
                
                do {
                    try self.fetchResultsController.performFetch()
                } catch {
                    let fetchError = error as NSError
                    print("Unable to Perform Fetch Request")
                    print("\(fetchError), \(fetchError.localizedDescription)")
                }
                
                self.updateView()
                
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        
    }
    
    @objc func applicationDidEnterBackground(_ notification: Notification) {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Unable to Save Changes")
            print("\(error), \(error.localizedDescription)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destinationViewController = segue.destination as? ShowWorkoutViewController else { return }
        
        // Configure View Controller
        destinationViewController.managedObjectContext = persistentContainer.viewContext
        
        if let indexPath = tableView.indexPathForSelectedRow, segue.identifier == "ShowWorkout" {
            // Configure View Controller
            destinationViewController.workout = fetchResultsController.object(at: indexPath)
            destinationViewController.controllerTitle = "Edit Workout"
            destinationViewController.selectedPickerRow = Int(fetchResultsController.object(at: indexPath).seconds)
        }
        
    }
    
    func setupView() {
        updateView()
    }
    
    fileprivate func updateView() {
        
        var hasWorkouts = false
        
        if let workouts = fetchResultsController.fetchedObjects {
            hasWorkouts = workouts.count > 0
        }
        
        //tableView.isHidden = !hasWorkouts
        _noWorkoutsMessage.isHidden = hasWorkouts
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = fetchResultsController.fetchedObjects else { return 0 }
        
        if workouts.count <= 1 {
            _playAllButton.isEnabled = false
        } else {
            _playAllButton.isEnabled = true
        }
        
        return workouts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if the table is asked to delete
        if editingStyle == .delete {
            // Fetch the specific row in table
            let workout = fetchResultsController.object(at: indexPath)
            // Remove fetched row
            workout.managedObjectContext?.delete(workout)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // update the model
        //timerStore.moveTimer(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
    
    func configure(_ cell: TimerCell, at indexPath: IndexPath) {
        
        // Fetch Workout
        let workout = fetchResultsController.object(at: indexPath)
        
        cell.workoutLabel?.text = workout.workout
        cell.secondsLabel?.text = workout.seconds.description
        
        // Assign the middle timer text to be the same as the seconds time
        cell.countdownLabel?.text = workout.seconds.description
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
}

extension TimerViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
        
        updateView()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break;
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? TimerCell {
                configure(cell, at: indexPath)
            }
            break;
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
            break;

        }
    }

    
}

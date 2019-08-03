//
//  TimerViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData
import FLAnimatedImage

class TimerViewController: UIViewController {
    
    private let persistentContainer = NSPersistentContainer(name: "Workouts")
    
    @IBOutlet weak var tableView: UITableView!
    
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
        
        var dwi: DispatchWorkItem?
        
        if _playAllButton.titleLabel?.text == "Play All" {
            
            _addNewTimer.isEnabled = false
            
            _playAllButton.setTitle("Stop All", for: .normal)
            
            for cell in cells {
                cell.playCellButton.isEnabled = false
            }
            
            dwi = DispatchWorkItem {
                for cell in cells {
                    if dwi!.isCancelled {
                        break
                    }
                    semaphore.wait()
                    cell.playAll(semaphore: semaphore)
                }
            }
            
            DispatchQueue.global().async(execute: dwi!)
            
        }
        
        if _playAllButton.titleLabel?.text == "Stop All" {
            
            DispatchQueue.global().async {
                dwi?.cancel()
            }
            
            for cell in cells {
                cell.stopAllCell()
                cell.resetAllCells(semaphore: semaphore)
                tableView.reloadData()
            }
            
            _playAllButton.setTitle("Play All", for: .normal)
            _addNewTimer.isEnabled = true
        }
        
    }
    
    @IBOutlet weak var _addNewTimer: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.estimatedRowHeight = 400
        tableView.rowHeight = UITableView.automaticDimension
        
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
            destinationViewController.saveButton.isEnabled = true
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
    
    
    
    func configure(_ cell: TimerCell, at indexPath: IndexPath) {
        
        // Fetch Workout
        let workout = fetchResultsController.object(at: indexPath)
        
        let image: FLAnimatedImage? = FLAnimatedImage.init(animatedGIFData: workout.workoutImage)
        
        cell.workoutLabel?.text = workout.workout
        cell.secondsLabel?.text = workout.seconds.description
        
        // Assign the middle timer text to be the same as the seconds time
        cell.countdownLabel?.text = workout.seconds.description
        cell.workoutImage?.animatedImage = image
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
}

extension TimerViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = fetchResultsController.fetchedObjects else { return 0 }
        
        if workouts.count <= 1 {
            _playAllButton.isEnabled = false
        } else {
            _playAllButton.isEnabled = true
        }
        
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TimerCell", for: indexPath) as! TimerCell
        
        configure(cell, at: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        // if the table is asked to delete
        if editingStyle == .delete {
            // Fetch the specific row in table
            let workout = fetchResultsController.object(at: indexPath)
            // Remove fetched row
            workout.managedObjectContext?.delete(workout)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // update the model
        //timerStore.moveTimer(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
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

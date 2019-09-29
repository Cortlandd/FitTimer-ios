//
//  WorkoutViewController.swift
//  Fit Timer
//
//  Created by User 1 on 8/20/18.
//  Copyright © 2018 Cortland Walker. All rights reserved.
//

import UIKit
import CoreData
import FLAnimatedImage

class WorkoutViewController: UIViewController {
    
    private let persistentContainer = NSPersistentContainer(name: "Workouts")
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet var _noWorkoutsMessage: UIView!
    
    var expandedCellsIndexes = [Int]()    
    var semaphore: DispatchSemaphore?
    var dwi: DispatchWorkItem?
    var finishedSemaphore: DispatchSemaphore?
    
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
        
        let cells = self.tableView.visibleCells as! [FullWorkoutCell]
        
        if _playAllButton.titleLabel?.text == "Play All" {
            
            _addNewTimer.isEnabled = false
            _playAllButton.setTitle("Stop All", for: .normal)
            
            for cell in cells {
                cell.btnPlay.isHidden = true
            }
            
            dwi = DispatchWorkItem {
                for cell in cells {
                    if self.dwi!.isCancelled {
                        break
                    }
                    self.semaphore!.wait()
                    cell.playAll()
                }
            }
            
            DispatchQueue.global().async(execute: dwi!)
            
        }
        
        if _playAllButton.titleLabel?.text == "Stop All" {

            DispatchQueue.global().async {
                self.dwi?.cancel()
            }

            for cell in cells {
                cell.fullWorkoutCellState = .stoppedAll
                cell.countdownTimer.end()
                //cell.stopAllCell()
                //cell.resetAllCells(semaphore: semaphore)
                cell.btnPlay.isHidden = false
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
        
        tableView.register(UINib(nibName: "FullWorkoutCell", bundle: nil), forCellReuseIdentifier: "FullWorkoutCell")
        tableView.backgroundView = _noWorkoutsMessage
        
        semaphore = DispatchSemaphore(value: 1)
        
        loadWorkouts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(applicationDidEnterBackground(_:)), name: UIApplication.didEnterBackgroundNotification, object: nil)
        
    }
    
    func loadWorkouts() {
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
    }
    
    func reloadTableViewAtIndex(_ index: Int) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.tableView.performBatchUpdates(nil, completion: nil)
        }
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
        
        if segue.destination is AddWorkoutViewController {
            let viewController = segue.destination as! AddWorkoutViewController
            viewController.managedObjectContext = persistentContainer.viewContext
        }
        guard let destinationViewController = segue.destination as? EditWorkoutViewController else { return }
        
        // Configure View Controller
        destinationViewController.managedObjectContext = persistentContainer.viewContext
        
        switch segue.identifier {
        case "ShowWorkout":
            print("Showing Activity")
            if let indexPath = tableView.indexPathForSelectedRow {
                // Configure View Controller
                destinationViewController.workout = fetchResultsController.object(at: indexPath)
                destinationViewController.selectedPickerRow = Int(fetchResultsController.object(at: indexPath).seconds)
            }
        default:
            preconditionFailure("Unexpected segue identifier")
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
    
    func configure(_ cell: FullWorkoutCell, at indexPath: IndexPath) {
        
        // Fetch Workout
        let workout = fetchResultsController.object(at: indexPath)
        
        let totalTime = workout.hours * (60 * 60) + workout.minutes * 60 + workout.seconds * 1
        
        let image: FLAnimatedImage? = FLAnimatedImage.init(animatedGIFData: workout.workoutImage)
        
        cell.delegate = self
        
        cell.index = indexPath.row
        
        let expanded = expandedCellsIndexes.contains(indexPath.row)
        
        cell.state = expanded ? .expanded : .collapsed
        
        cell.workoutLabel?.text = workout.workout
        //cell.secondsLabel?.text = workout.seconds.description
        
        cell.countdownTimer.counterLabel.text = cell.getHoursAndMinutesAndSeconds(remainingSeconds: Int(totalTime))
        cell.workoutImage.animatedImage = image
        
        cell.semaphore = self.semaphore
        //;
        cell.currentCount = Int(totalTime)
        
        cell.reloadUI()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
}

extension WorkoutViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let expanded = expandedCellsIndexes.contains(indexPath.row)
        return expanded ? 422 : 162
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let workouts = fetchResultsController.fetchedObjects else { return 0 }
        
        if workouts.count <= 1 {
            _playAllButton.isHidden = true
        } else {
            _playAllButton.isHidden = false
        }
        
        return workouts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "FullWorkoutCell", for: indexPath) as! FullWorkoutCell
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "ShowWorkout", sender: nil)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // update the model
        //timerStore.moveTimer(from: sourceIndexPath.row, to: destinationIndexPath.row)
    }
}

extension WorkoutViewController: NSFetchedResultsControllerDelegate {
    
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
                do {
                    try persistentContainer.viewContext.save()
                } catch {
                    print("Unable to Save Changes")
                    print("\(error), \(error.localizedDescription)")
                }
                updateView()
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? FullWorkoutCell {
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

extension WorkoutViewController: FullWorkoutCellDelegate {
    
    func workoutCellDidPressedPlay(_ exerciseCell: FullWorkoutCell, index: Int) {
        expandedCellsIndexes.append(index)
        reloadTableViewAtIndex(index)
    }
    
    func workoutCellDidPressedStop(_ exerciseCell: FullWorkoutCell, index: Int) {
        if let indexToRemove = expandedCellsIndexes.firstIndex(of: index) {
            expandedCellsIndexes.remove(at: indexToRemove)
            reloadTableViewAtIndex(index)
        }
    }
    
    func workoutDidFinish(_ workoutCell: FullWorkoutCell, index: Int) {
        // TODO MARK find out if this is allocating memory each time
        let cells = self.tableView.visibleCells as! [FullWorkoutCell]
        
        // Check if finished workout is the last in index
        if index == cells.last?.index {
            
            print("Workout Complete")
            
            DispatchQueue.global().async {
                self.dwi?.cancel()
            }
            
            for cell in cells {
                cell.fullWorkoutCellState = .stoppedAll
                cell.countdownTimer.end()
                //cell.stopAllCell()
                //cell.resetAllCells(semaphore: semaphore)
                cell.btnPlay.isHidden = false
                tableView.reloadData()
            }
            
            _playAllButton.setTitle("Play All", for: .normal)
            _addNewTimer.isEnabled = true
            
        }
    }
    
}

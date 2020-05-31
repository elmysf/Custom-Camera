//
//  ListDataViewController.swift
//  CustomCamera
//
//  Created by Ihwan ID on 30/05/20.
//  Copyright © 2020 Sufiandy Elmy. All rights reserved.
//

import UIKit
import CoreData

class ListDataViewController: UIViewController {
    
    
    @IBOutlet weak var tableView: UITableView!
    var fetchedResultsController: NSFetchedResultsController<Waste>!
    let viewContext = CoreDataManager.shared.persistentContainer.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSavedData()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    
    func loadSavedData() {
        if fetchedResultsController == nil {
            let request = NSFetchRequest<Waste>(entityName: "Waste")
            let sort = NSSortDescriptor(key: "name", ascending: false)
            request.sortDescriptors = [sort]
            request.fetchBatchSize = 20
            
            fetchedResultsController = NSFetchedResultsController(fetchRequest: request, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
            fetchedResultsController.delegate = self
        }
        
        do {
            try fetchedResultsController.performFetch()
            tableView.reloadData()
        } catch {
            print("Fetch failed")
        }
    }
    
}

extension ListDataViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("clicked")
    }
}

extension ListDataViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") else {
                return UITableViewCell(style: .default, reuseIdentifier: "cell")
            }
            return cell
        }()
        
        let waste = fetchedResultsController.object(at: indexPath)
        cell.textLabel?.text = "\(waste.name!)"
        cell.imageView?.image = UIImage(data: waste.image!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let action = UIContextualAction(style: .destructive, title: "Delete", handler: { (action, view, completionHandler) in
            
            let waste = self.fetchedResultsController.object(at: indexPath)
            CoreDataManager.shared.persistentContainer.viewContext.delete(waste)
            CoreDataManager.shared.saveContext()
        })
        action.image = makeSymbolImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [action])
        
        return configuration
    }
    
    func makeSymbolImage(systemName: String) -> UIImage? {
        let configuration = UIImage.SymbolConfiguration(scale: .large)
        let image = UIImage(systemName: systemName, withConfiguration: configuration)
        
        return image
    }
    
}

extension ListDataViewController: NSFetchedResultsControllerDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.moveRow(at: indexPath!, to: newIndexPath!)
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

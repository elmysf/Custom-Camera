//
//  CoreDataManager.swift
//  CustomCamera
//
//  Created by Ihwan ID on 30/05/20.
//  Copyright © 2020 Sufiandy Elmy. All rights reserved.
//

import CoreData
import UIKit

struct CoreDataManager {
    
    static let shared = CoreDataManager()
    
    let persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "CustomCamera")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Loading of store failed \(error)")
            }
        }
        
        return container
    }()
    
    @discardableResult
    func createWaste(name: String, image: UIImage) -> Waste? {
        let context = persistentContainer.viewContext
        
        let waste = NSEntityDescription.insertNewObject(forEntityName: "Waste", into: context) as! Waste // NSManagedObject
        
        let imageData = image.jpegData(compressionQuality: 1.0)
        waste.name = name
        waste.image = imageData
        
        do {
            try context.save()
            return waste
        } catch let createError {
            print("Failed to create: \(createError)")
        }
        
        return nil
    }
    
    func fetchWastes() -> [Waste]? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Waste>(entityName: "Waste")
        
        do {
            let wastes = try context.fetch(fetchRequest)
            return wastes
        } catch let fetchError {
            print("Failed to fetch wastes: \(fetchError)")
        }
        
        return nil
    }
    
    func fetchWaste(withName name: String) -> Waste? {
        let context = persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<Waste>(entityName: "Waste")
        fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "name == %@", name)
        
        do {
            let wastes = try context.fetch(fetchRequest)
            return wastes.first
        } catch let fetchError {
            print("Failed to fetch: \(fetchError)")
        }
        
        return nil
    }
    
    func updateWaste(waste: Waste) {
        let context = persistentContainer.viewContext
        
        do {
            try context.save()
        } catch let createError {
            print("Failed to update: \(createError)")
        }
    }
    
    func deleteWaste(waste: Waste) {
        let context = persistentContainer.viewContext
        context.delete(waste)
        
        do {
            try context.save()
        } catch let saveError {
            print("Failed to delete: \(saveError)")
        }
    }
    
    func saveContext() {
        if persistentContainer.viewContext.hasChanges {
            do {
                try persistentContainer.viewContext.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }
    }
    
}

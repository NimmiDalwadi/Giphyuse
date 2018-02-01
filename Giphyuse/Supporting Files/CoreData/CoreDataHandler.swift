//
//  CoreDataHandler.swift
//  Giphyuse
//
//  Created by Rajshekhar Modi on 2018-01-26.
//  Copyright © 2018 Nimmi. All rights reserved.
//

import UIKit
import  CoreData

// Entity created Favourite with id and imageURL as column atrributes
class CoreDataHandler: NSObject {

    private class func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    //This is called when user taps on the favourite (unfilled) star icon
    class func saveObject(id:String, imageurl:String) -> Bool {
        let context = CoreDataHandler.getContext()
        
        //retrieve the entity that we created
        let entity = NSEntityDescription.entity(forEntityName: "Favourite", in: context)
        let manageObject = NSManagedObject(entity: entity!, insertInto: context)

        //set the entity values
        manageObject.setValue(id, forKey: "id")
        manageObject.setValue(imageurl, forKey: "imageURL")
        
        //save the object
        do{
            try context.save()
            return true
        } catch {
            return false
        }
    }
    
    //This is called when the user taps on the second tab for displaying GIFs as favourites
    class func fetchObject(completionHandler:@escaping (_ favorites: [Favourite]?, _ error: String?) -> Void) {
        let context = CoreDataHandler.getContext()
        
        //create a fetch request, telling it about the entity
        let fatchRequest: NSFetchRequest<Favourite> = Favourite.fetchRequest()

        do {
            //go get the results
            var favourites =  try context.fetch(fatchRequest)
            favourites  = favourites.reversed()
            completionHandler(favourites, nil)

        } catch let error as NSError {
            print("Error in fetch :\(error)")
            completionHandler(nil, error.localizedDescription)

        }
    }
    
    //This is called when user unfavourites any of the GIFs
    class func deleteObject(passid:String) -> Bool {
        let context = CoreDataHandler.getContext()
        let fatchRequest: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        fatchRequest.predicate = NSPredicate(format: "id = %@", passid)

        do{
            let favourites  =  try context.fetch(fatchRequest)
            for fav in favourites
            {
                context.delete(fav)
            }
            do {
                try context.save()
            } catch let error as NSError{
                print("Error in fetch :\(error)")
                return false
            }
            return true
        } catch let error as NSError {
            print("Error in fetch :\(error)")
            return false
        }
    }
    
    //Peform a check for favourite so as to display the filled star (favourite) while loading of GIFs (search/trending)
    class func checkFavouriteAvailable(passid: String) -> Bool
    {
        let context = CoreDataHandler.getContext()
        let fatchRequest: NSFetchRequest<Favourite> = Favourite.fetchRequest()
        fatchRequest.predicate = NSPredicate(format: "id = %@", passid)
        
        var results: [NSManagedObject] = []
        
        do {
            results =  try context.fetch(fatchRequest)
           
        } catch let error as NSError {
            print("Error in fetch :\(error)")
            
        }
        return results.count > 0
    }
    
}

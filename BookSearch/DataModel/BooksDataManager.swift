//
//  BooksDataManager.swift
//  GoogleBooksSearch
//
//  Created by RADHIKA SHARMA on 8/19/18.
//  Copyright © 2018 RADHIKA SHARMA. All rights reserved.
//

import UIKit
import CoreData

class BooksDataManager: NSObject {
    
    enum DefaultData: String {
        case defaultAuthor = "J.K. Rowling"
        case defaultTitle = "Harry Potter"
        case defaultPublisher = "Penguin"
        case defaultIdentifier = "AXF567GHJ789"
        case defaultCategory = "Fiction"
    }

    static let sharedInstance = BooksDataManager()
    private var persistentContainer: NSPersistentContainer
    
    private override init() {
        self.persistentContainer = NSPersistentContainer(name: "BooksModel")
        let baseUrl = FileManager.default.urls(for: .documentDirectory, in:.userDomainMask).first!
        
        let fullDbUrl = baseUrl.appendingPathComponent("GoogleBookStore.sqlite")
        let descp = NSPersistentStoreDescription(url: fullDbUrl)
        descp.type = NSSQLiteStoreType;
        descp.shouldInferMappingModelAutomatically = true
        descp.shouldMigrateStoreAutomatically = true
        self.persistentContainer.persistentStoreDescriptions = [descp]
        
        
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace with proper error handling
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
    }
        
    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace with proper error handling
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getBooksFromStore(category: String,  completion:@escaping([BookViewModel
        ]?, Error?)->Void) {
        
        let privateContext = self.persistentContainer.newBackgroundContext()
        
        privateContext.perform {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Books")
            request.predicate = NSPredicate(format: "category = %@", category)
            request.returnsObjectsAsFaults = false
            do {
                let resArray = try privateContext.fetch(request)
                var resultArray = [BookViewModel] ()
                for data in resArray as! [NSManagedObject] {
                    if let book = data as? Books {
                        let bookTtl  = book.title ?? DefaultData.defaultTitle.rawValue
                        let bookId = book.identifier ?? DefaultData.defaultIdentifier.rawValue
                        let bookAuth  = book.author ?? DefaultData.defaultAuthor.rawValue
                        let bookPub = book.publisher ?? DefaultData.defaultPublisher.rawValue
                       
                        let bookModel = BookViewModel(identifier:bookId, title: bookTtl, author: bookAuth, publisher: bookPub)
                        bookModel.subtitle = book.subtitle ?? " "
                        
                        bookModel.category = book.category ?? DefaultData.defaultCategory.rawValue
                        
                        if let thmbURI = book.thumbnailUri {
                            bookModel.thumbnailURI = thmbURI
                        }
                        
                        if let thmbImg = book.thumbnail {
                            bookModel.thumbnail = UIImage(data: thmbImg)
                        }
                        resultArray.append(bookModel)
                    }
                }
               completion(resultArray, nil)
            } catch {
                print("Data fetch Failed")
                completion(nil, error)
            }
        }
    }
    
    public func addBooksToStore(booksArray: [BookViewModel]) -> Bool {
        var success = true
        let privateContext = self.persistentContainer.newBackgroundContext()
        
        privateContext.perform {
    
            for book in booksArray {
                let entity = NSEntityDescription.entity(forEntityName: "Books", in: privateContext)
                let newBook = NSManagedObject(entity: entity!, insertInto: privateContext)
                newBook.setValue(book.authors, forKey:"author")
                newBook.setValue(book.title, forKey:"title")
                newBook.setValue(book.publisher, forKey:"publisher")
                newBook.setValue(book.identifier, forKey:"identifier")
                newBook.setValue(book.category, forKey:"category")
                newBook.setValue(book.thumbnailURI, forKey:"thumbnailUri")
                
                if let img = book.thumbnail {
                    let imgData = UIImagePNGRepresentation(img)
                    newBook.setValue(imgData, forKey:"thumbnail")
                }
            }
            
            do {
                try privateContext.save()
            } catch {
                print("Failed saving")
                success = false
            }
        }
        
        
        return success
    }
   
    public func updateBookThumbnail(identifier: String, imageData: Data) {
        let privateContext = self.persistentContainer.newBackgroundContext()
        
        privateContext.performAndWait {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Books")
            request.predicate = NSPredicate(format: "identifier = %@", identifier)
            request.returnsObjectsAsFaults = false
            do {
                let resArray = try privateContext.fetch(request)
                for data in resArray as! [Books] {
                    data.thumbnail = imageData
                }
            } catch {
                print("Book fetch Failed")
            }
            
            do {
                try privateContext.save()
            } catch {
                print("Failed saving")
            }
        }
    }
}

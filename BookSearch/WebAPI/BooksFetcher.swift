//
//  BooksFetcher.swift
//  GoogleBooksSearch
//
//  Created by RADHIKA SHARMA on 8/19/18.
//  Copyright © 2018 RADHIKA SHARMA. All rights reserved.
//

import UIKit


class BooksFetcher: NSObject {
    
    static let apiKey = String("AIzaSyAH7IthXfsjd5xGPouzborgOGAIcp35sJA")
    static let baseUrl = String("https://www.googleapis.com/books/v1/volumes")
    static let maxBooks = 30
    
    enum JSONError: String, Error {
        case NoData = "ERROR: no data"
        case ConversionFailed = "ERROR: conversion from JSON failed"
        case BadData = "ERROR: bad data"
    }
    
    public class  func getVolumesFor(category: String, completion:@escaping([BookViewModel
        ]?, Error?)->Void) {
        let session = URLSession.shared
        var urlStr = String(format: "%@?q=%@&key=%@",baseUrl,category,apiKey)
        
        if let escapedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)  {
             urlStr = String(format: "%@?q=%@&key=%@",baseUrl,escapedCategory,apiKey)
        }
        
        guard let listUrl = URL(string: urlStr)  else {
            let error = NSError(domain: "Bad Url", code: 510)
            completion(nil, error)
            return
        }
        
        let task = session.dataTask(with: listUrl){ (data, response, error) in
            do {
                guard let data = data else {
                    throw JSONError.NoData
                }
                guard let json = try JSONSerialization.jsonObject(with: data, options:.allowFragments) as? Dictionary<String, Any> else {
                    throw JSONError.ConversionFailed
                }
                //print(json)
                
                if let items = json["items"], let arr = items as? Array<Dictionary<String, Any>> {
                    
                    let books = BooksFetcher .parseBookArray(category: category, items: arr)
                    _  = BooksDataManager.sharedInstance.addBooksToStore(booksArray: books)
                    
                    completion(books, nil)
                } else {
                    throw JSONError.BadData
                }
            } catch let error as JSONError {
                print(error.rawValue)
                completion(nil, error)
                
            } catch let error as NSError {
                print(error.debugDescription)
                completion(nil, error)
            }
        }
        task.resume()
    }
    
    public class func parseBookArray(category: String, items: Array<Dictionary<String, Any>>) -> [BookViewModel] {
        
        var books = [BookViewModel]()
        var count = 0
        for item in items {
            if count > maxBooks { //For demo purpose will only be parsing 20 items
                break
            }
            
            var identifier = " "
            if let id = item["id"] as? String {
                identifier = id
            }
            
            let bookModel = BookViewModel(identifier: identifier, title: " ", author: " ", publisher: " ")
            
            bookModel.category = category
            
            if let info = item["volumeInfo"] as? NSDictionary {
                bookModel.title = info.value(forKey: "title") as? String  ?? " "
                bookModel.subtitle = info.value(forKey: "subtitle") as? String ?? " "
        
                var author = " "
                if let ath = info.value(forKey: "authors") as? Array<String> {
                    author = ath.joined(separator: ",")
                    bookModel.authors = author
                }
                
                bookModel.publisher = info.value(forKey: "publisher") as? String ?? " "
                
                if let tmbUrlStr = info.value(forKeyPath: "imageLinks.smallThumbnail") as? String, let tmbUrl = URL(string: tmbUrlStr) {
                    bookModel.thumbnailURI = tmbUrl
                }
                
                if let thumbnailImg = UIImage(named: "BookCover") {
                    bookModel.thumbnail = thumbnailImg
                }
            }
            
            books.append(bookModel)
            count += 1
        }
        
        return books
    }
    
    class func getBookThumbnail(thumbnailURL: URL, completion:@escaping(UIImage?, Error?)->Void){
        
        let session = URLSession.shared
        let task = session.dataTask(with: thumbnailURL) { (data, response, error) in
            
            if (error != nil){
                completion(nil, error)
            }
            if (data != nil){
                let image = UIImage(data:data!)!
                completion(image, nil)
            }
        }
        task.resume()
        
    }
    
    class func getBookThumbnails(books: [BookViewModel], completion:@escaping([BookViewModel], Bool)->Void) {
        var doneCount = 0
        var newArray = [BookViewModel]()
        for i in 0..<books.count {
            let imgUrl = books[i].thumbnailURI
            let identifier = books[i].identifier
            newArray.append(books[i])
            if (imgUrl != nil && identifier != " ") {
                let semaphore = DispatchSemaphore(value: 0)
                BooksFetcher.getBookThumbnail(thumbnailURL: imgUrl!){ (image, error) in
                    doneCount += 1
                    if(error != nil){
                        print(error!)
                    } else {
                        if (image != nil) {
                            newArray[i].thumbnail = image
                            if let imgData = UIImagePNGRepresentation(image!) {
                                BooksDataManager.sharedInstance.updateBookThumbnail(identifier: identifier, imageData: imgData)
                            }
                        }
                    }
                    semaphore.signal()
                }
                semaphore.wait()
                if(doneCount == books.count) {
                    completion(newArray, true)
                }
            } //if(imgUrl != nil)
        }
    }

}

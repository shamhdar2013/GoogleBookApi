//
//  BookViewModel.swift
//  GoogleBooksSearch
//
//  Created by RADHIKA SHARMA on 8/19/18.
//  Copyright © 2018 RADHIKA SHARMA. All rights reserved.
//

import UIKit

class BookViewModel {
    var identifier: String
    var title: String
    var authors: String
    var publisher: String
    
    var subtitle: String
    var thumbnail: UIImage?
    var category: String
    var thumbnailURI: URL?
    
    public init(identifier: String, title: String, author: String, publisher: String) {
        self.identifier = identifier
        self.title = title
        self.authors = author
        self.publisher = publisher
        self.subtitle = " "
        self.category = "Generic"
    
        if let url = URL(string: "http://books.google.com/books/content?id=0p_3DcMR5okC&printsec=frontcover&img=1&zoom=5&edge=curl&source=gbs_api") {
            self.thumbnailURI = url
        }
        
        if let image = UIImage(named: "BookCover") {
            self.thumbnail = image
        } 
    }
}

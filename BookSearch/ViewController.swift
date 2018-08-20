//
//  ViewController.swift
//  BookSearch
//
//  Created by RADHIKA SHARMA on 8/19/18.
//  Copyright © 2018 RADHIKA SHARMA. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var bookTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var books = [BookViewModel]()
    var searchInProgress = false

    override func viewDidLoad() {
        super.viewDidLoad()
        let cellNib = UINib(nibName: "BookTableViewCell", bundle: nil)
        bookTableView.register(cellNib, forCellReuseIdentifier: "BookCell")
        bookTableView.dataSource = self
        bookTableView.delegate = self
        self.updateBooksView(category: "Cardio")
        self.searchBar.delegate = self
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func updateBooksView(category: String) {
        
        BooksDataManager.sharedInstance.getBooksFromStore(category:category) { (array, error) in
            if let bookarr = array, !bookarr.isEmpty {
                DispatchQueue.main.async {
                    self.books = array!
                    self.bookTableView.reloadData()
                }
            } else {
                
                BooksFetcher.getVolumesFor(category: category) { (array, error) in
                    
                    if  array != nil {
                        DispatchQueue.main.async {
                            self.books = array!
                            self.bookTableView.reloadData()
                        }
                        
                        DispatchQueue.global().async{
                            BooksFetcher.getBookThumbnails(books: array!) { (bkArray, success) in
                                DispatchQueue.main.async {
                                    self.books = bkArray
                                    self.bookTableView.reloadData()
                                }
                            }
                        }//Dispatch.global
                    }//array != nil
                }//getVolumesFor
            }//else array
        }
    }

}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return books.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "BookCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? BookTableViewCell  else {
            fatalError("The dequeued cell is not an instance of BookTableViewCell.")
        }
        let row = indexPath.row
        cell.configure(book: self.books[row], item: row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = CGFloat(270.0)
        return height
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchInProgress = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let category = searchBar.text {
            self.updateBooksView(category: category)
            searchInProgress = false
        }
    }
    
}


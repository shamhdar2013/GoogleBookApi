//
//  BookTableViewCell.swift
//  BookSearch
//
//  Created by RADHIKA SHARMA on 8/19/18.
//  Copyright © 2018 RADHIKA SHARMA. All rights reserved.
//

import UIKit

class BookTableViewCell: UITableViewCell {
    @IBOutlet weak var bookCoverView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(book: BookViewModel, item: Int) {
        self.bookCoverView.image = book.thumbnail ?? UIImage(named:"BookCover")
        self.titleLabel.text = book.title
        self.authorLabel.text = String(format:"By: %@", book.authors)
    }
    
}

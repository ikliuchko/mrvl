//
//  ComicsCell.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/7/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import UIKit
import Kingfisher

protocol ComicsTableViewCellDelegate: class {
    func comicsCellDidAskToAdd(_ cell: ComicsTableViewCell, comics: Comics, toFavorites: Bool)
//    func comicsCellDidLoadImageWithProportion(_ cell: ComicsTableViewCell, ratio: CGFloat)
}

class ComicsTableViewCell: UITableViewCell {
    // MARK: - Properties
    
    @IBOutlet private var titleLabel: UILabel?
    @IBOutlet var mainImage: UIImageView?
    @IBOutlet private var favoriteIconImageView: UIImageView?
    
    private var comics: Comics? {
        didSet {
            guard titleLabel != nil, mainImage != nil,
            let comics = comics else { return }
            updateUI(with: comics)
        }
    }
    
    weak var delegate: ComicsTableViewCellDelegate?
    
    private var isFavorite = false
    
    
    
    // MARK: - Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(addToFavoritesPressed(_:)))
        favoriteIconImageView?.addGestureRecognizer(tapGR)
        
        guard let comics = comics else { return }
        updateUI(with: comics)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.comics = nil
    }
    
    func update(with comics: Comics) {
        self.comics = comics
    }
    
    private func updateUI(with comics: Comics) {
        titleLabel?.text = comics.title
        favoriteIconImageView?.image = comics.isFavorite
        ? UIImage(named: "Favorite")
        : UIImage(named: "AddToFavorites")
    }
    
   @objc private func addToFavoritesPressed(_ sender: UITapGestureRecognizer) {
        guard let comics = comics else { return }
        delegate?.comicsCellDidAskToAdd(self, comics: comics, toFavorites: !comics.isFavorite)
    }
}

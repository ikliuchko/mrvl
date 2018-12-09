//
//  ComicsDetailViewController.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import UIKit
import Swinject

class ComicsDetailsViewController: UIViewController {
    // MARK: - Properties
    
    @IBOutlet private var mainImageView: UIImageView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var charactersLabel: UILabel!
    @IBOutlet private var creatorsLabel: UILabel!
    @IBOutlet private var favoritesImageView: UIImageView!
    
    private var comics: Comics?
    
    private var favoritesManager: FavoritesManager?
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        favoritesManager = DIContainer.defaultResolver.resolve(FavoritesManager.self)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(addToFavoritesPressed(_:)))
        favoritesImageView?.addGestureRecognizer(tapGR)
        
        updateUI(with: comics)
    }
    
    
    
    // MARK: - Public
    
    func update(with comics: Comics) {
        self.comics = comics
        updateUI(with: comics)
    }
    
    
    
    // MARK: - Private
    
    fileprivate func updateUI(with comics: Comics?) {
        guard let comics = comics, isViewLoaded else { return }
        titleLabel.text = comics.title
        charactersLabel.text = comics.characters.isEmpty
            ? nil
            : "Characters: " + comics.characters.joined(separator: ", ")
        creatorsLabel.text = comics.creators.isEmpty
            ? nil
            : "Creators: " + comics.creators.joined(separator: ", ")
        guard let imageURL = URL(string: comics.image) else { return }
        mainImageView.kf.setImage(with: imageURL)
        favoritesImageView.image = comics.isFavorite
            ? UIImage(named: "Favorite")
            : UIImage(named: "AddToFavorites")
    }
    
    @objc private func addToFavoritesPressed(_ sender: UITapGestureRecognizer) {
        guard let comics = comics else { return }
        favoritesManager?.comics(with: comics.id, shouldBeAddedToFavorites: !comics.isFavorite)
            .done { [weak self] _ -> Void in
                comics.setFavorite(!comics.isFavorite)
                self?.updateUI(with: comics)
        }
            .catch { _ in }
    }
}

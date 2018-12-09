//
//  SearchViewController.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import UIKit
import Swinject
import PromiseKit
import Foundation

class SearchViewController: UIViewController {
    // MARK: - Internal types
    private struct Constants {
        static let cellIdentifier = "comicsCell"
        static let cellHeight: CGFloat = 409.0
        static let detailsVCID = "DetailsVC"
        static let cellNibName = "ComicsTableViewCell"
    }
    
    
    
    // MARK: - Properties
    
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    
    private var searchManager: SearchManager?
    private var favoritesManager: FavoritesManager?
    
    fileprivate var searchResult: [Comics] = []
    fileprivate var favorites: [String] = []
    fileprivate var ratioDict: [String: CGFloat] = [:]
    fileprivate var selectedItemIndexPath: IndexPath?
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        searchBar.delegate = self
        
        setupDependencies()
        setupInitialUI()
        
        favoritesManager?.getFavoritesIDs()
            .done { [weak self] ids in
                self?.favorites = ids
            }
            .done { [weak self] in
                self?.tableView.reloadData()
            }
            .catch { _ in }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let indexPath = selectedItemIndexPath else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    
    
    // MARK: - Private
    
    fileprivate func search(_ word: String) {
        searchManager?.searchForComics(with: word)
            .done { [weak self] comics -> Void in
                guard let `self` = self else { return }
                comics.forEach {
                    guard self.favorites.contains($0.id) else { return }
                    $0.setFavorite(true)
                }
                self.searchResult = comics
                self.tableView.reloadData()
                self.tableView.isHidden = comics.isEmpty
            }
            .catch { _ in }
    }
    
    private func setupDependencies() {
        searchManager = DIContainer.defaultResolver.resolve(SearchManager.self)
        favoritesManager = DIContainer.defaultResolver.resolve(FavoritesManager.self)
    }
    
    private func setupInitialUI() {
        searchBar.placeholder = "Enter title to search"
        tableView.isHidden = true
    }
}

// MARK: - UISearchBarDelegate
extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard searchText.count > 2 else { return }
        search(searchText)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text else { return }
        searchBar.endEditing(true)
        search(searchText)
    }
}



// MARK: - UITableViewDelegate, UITableViewDataSource

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(searchResult.count, GlobalConstants.itemsToDisplay)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier)
        guard let currentCell = cell as? ComicsTableViewCell else { return UITableViewCell() }
        currentCell.delegate = self
        currentCell.update(with: searchResult[indexPath.row])
        if let imageURL = URL(string: searchResult[indexPath.row].image),
            let mainImage = currentCell.mainImage {
            mainImage.kf.indicatorType = .activity
            mainImage.kf.indicator?.view.backgroundColor = .black
            mainImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.5))]) { [weak self] image, _, _, _ in
                guard let self = self,
                    let image = image else { return }
                self.ratioDict[self.searchResult[indexPath.row].image] = image.size.width / image.size.height
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedComics = searchResult[indexPath.row]
        selectedItemIndexPath = indexPath
        guard let detailsVC = storyboard?.instantiateViewController(withIdentifier: Constants.detailsVCID) as? ComicsDetailsViewController else {
            return }
        detailsVC.update(with: selectedComics)
        navigationController?.show(detailsVC, sender: self)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let ratio = ratioDict[searchResult[indexPath.row].image] else { return Constants.cellHeight }
        return tableView.frame.width / ratio
    }
}



// MARK: - ComicsTableViewCellDelegate

extension SearchViewController: ComicsTableViewCellDelegate {
    func comicsCellDidAskToAdd(_ cell: ComicsTableViewCell, comics: Comics, toFavorites: Bool) {
        favoritesManager?.comics(with: comics.id, shouldBeAddedToFavorites: toFavorites)
            .done { [weak self] favs in
                guard let self = self else { return }
                comics.setFavorite(toFavorites)
                self.favorites = favs
                guard let indxPath = self.tableView.indexPath(for: cell) else { return }
                self.tableView.reloadRows(at: [indxPath], with: .none)
            }
            .catch { _ in }
    }
}

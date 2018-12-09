//
//  ComicsListViewController.swift
//  Marvel Comics
//
//  Created by Igor Kliuchko on 12/2/18.
//  Copyright © 2018 Igor Kliuchko. All rights reserved.
//

import PromiseKit
import Swinject

class ComicsListViewController: UIViewController {
    // MARK: - Internal types
    
    private struct Constants {
        static let cellIdentifier = "comicsCell"
        static let cellHeight: CGFloat = 409.0
        static let detailsVCID = "DetailsVC"
        static let cellNibName = "ComicsTableViewCell"
    }
    
    
    // MARK: - Properties
    
    @IBOutlet private weak var tableView: UITableView!
    
    private var comicsManager: ComicsManager?
    private var favoritesManager: FavoritesManager?
    
    private var comics: [Comics] = []
    private var favorites: [String] = []
    fileprivate var ratioDict: [String: CGFloat] = [:]
    var selectedItemIndexPath: IndexPath?
    
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupDependencies()
        
        tableView.register(UINib(nibName: Constants.cellNibName, bundle: nil), forCellReuseIdentifier: Constants.cellIdentifier)
        
        loadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let indexPath = selectedItemIndexPath else { return }
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    private func setupDependencies() {
        comicsManager = DIContainer.defaultResolver.resolve(ComicsManager.self)!
        favoritesManager = DIContainer.defaultResolver.resolve(FavoritesManager.self)!
    }
    
    private func loadData() {
        guard let favManager = favoritesManager,
            let comManager = comicsManager else { return }
        firstly {
            when(fulfilled: favManager.getFavoritesIDs(), comManager.getComicsList() )
            }
            .done { [weak self] favs, comics in
                comics.forEach {
                    guard favs.contains($0.id) else { return }
                    $0.setFavorite(true)
                }
                self?.comics = comics
                self?.favorites = favs
                self?.tableView.reloadData()
            }
            .catch { _ in }
    }
    
}



// MARK: - TableView datasource & delegate
extension ComicsListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedComics = comics[indexPath.row]
        selectedItemIndexPath = indexPath
        guard let detailsVC = storyboard?.instantiateViewController(withIdentifier: Constants.detailsVCID) as? ComicsDetailsViewController else {
            return }
        detailsVC.update(with: selectedComics)
        navigationController?.show(detailsVC, sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return min(comics.count, GlobalConstants.itemsToDisplay)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.cellIdentifier, for: indexPath)
        guard let currentCell = cell as? ComicsTableViewCell else { return UITableViewCell() }
        currentCell.delegate = self
        currentCell.update(with: comics[indexPath.row])
        if let imageURL = URL(string: comics[indexPath.row].image),
            let mainImage = currentCell.mainImage {
            mainImage.kf.indicatorType = .activity
            mainImage.kf.indicator?.view.backgroundColor = .black
            mainImage.kf.setImage(with: imageURL, options: [.transition(.fade(0.5))]) { [weak self] image, _, _, _ in
                guard let self = self,
                    let image = image else { return }
                self.ratioDict[self.comics[indexPath.row].image] = image.size.width / image.size.height
                tableView.beginUpdates()
                tableView.reloadRows(at: [indexPath], with: .none)
                tableView.endUpdates()
            }
        }
        return currentCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let ratio = ratioDict[comics[indexPath.row].image] else { return Constants.cellHeight }
        return tableView.frame.width / ratio
    }
}



// MARK: - ComicsTableViewCellDelegate

extension ComicsListViewController: ComicsTableViewCellDelegate {
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

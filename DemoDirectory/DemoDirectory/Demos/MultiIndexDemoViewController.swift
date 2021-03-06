//
//  MultiIndexDemoViewController.swift
//  development-pods-instantsearch
//
//  Created by Vladislav Fitc on 09/06/2019.
//  Copyright © 2019 Algolia. All rights reserved.
//

import Foundation
import InstantSearch
import UIKit

extension HitViewModel {
  
  static func movie(_ movie: Movie) -> Self {
    return HitViewModel()
      .set(\.imageViewConfigurator) { imageView in
        imageView.sd_setImage(with: movie.image, completed: .none)
        imageView.contentMode = .scaleAspectFit
      }
      .set(\.mainTitleConfigurator) { label in
        label.text = movie.title
        label.font = .systemFont(ofSize: 14, weight: .bold)
        label.numberOfLines = 0
      }
      .set(\.secondaryTitleConfigurator) { label in
        label.text = "\(movie.year)"
        label.font = .systemFont(ofSize: 12, weight: .regular)
      }
      .set(\.detailsTitleConfigurator) { label in
        label.text = movie.genre.joined(separator: ", ")
        label.font = .systemFont(ofSize: 12, weight: .light)
        label.numberOfLines = 0
      }
  }
  
}

class MultiIndexDemoViewController: UIViewController, InstantSearchCore.MultiIndexHitsController {
  
  func reload() {
    moviesCollectionView.reloadData()
    actorsCollectionView.reloadData()
  }
  
  func scrollToTop() {
    moviesCollectionView.scrollToFirstNonEmptySection()
    actorsCollectionView.scrollToFirstNonEmptySection()
  }

  weak var hitsSource: MultiIndexHitsSource?
  
  let multiIndexSearcher: MultiIndexSearcher
  let textFieldController: TextFieldController
  let queryInputInteractor: QueryInputInteractor
  let multiIndexHitsInteractor: MultiIndexHitsInteractor
  let searchBar: UISearchBar
  let moviesCollectionView: UICollectionView
  let actorsCollectionView: UICollectionView
  let cellIdentifier = "CellID"

  init() {
    searchBar = UISearchBar()
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = .horizontal
    moviesCollectionView = .init(frame: .zero, collectionViewLayout: flowLayout)
    
    let actorsFlowLayout = UICollectionViewFlowLayout()
    actorsFlowLayout.scrollDirection = .horizontal
    actorsCollectionView = .init(frame: .zero, collectionViewLayout: actorsFlowLayout)
    
    let indices = [
      Section.shopItems.index,
      Section.actors.index,
    ]
    multiIndexSearcher = .init(client: .demo, indices: indices)
    
    let hitsInteractors: [AnyHitsInteractor] = [
      HitsInteractor<Movie>(infiniteScrolling: .on(withOffset: 10), showItemsOnEmptyQuery: true),
      HitsInteractor<Hit<Actor>>(infiniteScrolling: .on(withOffset: 10), showItemsOnEmptyQuery: true),
    ]
    
    multiIndexHitsInteractor = .init(hitsInteractors: hitsInteractors)

    textFieldController = .init(searchBar: searchBar)
    queryInputInteractor = .init()
    
    super.init(nibName: nil, bundle: nil)
    
    setup()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
}

private extension MultiIndexDemoViewController {
  
  func section(for collectionView: UICollectionView) -> Section? {
    switch collectionView {
    case moviesCollectionView:
      return .shopItems
      
    case actorsCollectionView:
      return .actors

    default:
      return .none
    }
  }
  
  func setup() {
    queryInputInteractor.connectSearcher(multiIndexSearcher)
    queryInputInteractor.connectController(textFieldController)

    multiIndexHitsInteractor.connectSearcher(multiIndexSearcher)
    multiIndexHitsInteractor.connectController(self)
    
    multiIndexSearcher.search()
  }
  
  func configure(_ collectionView: UICollectionView) {
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.backgroundColor = .clear
  }
  
  func configureCollectionView() {
    moviesCollectionView.register(HitCollectionViewCell.self, forCellWithReuseIdentifier: Section.shopItems.cellIdentifier)
    actorsCollectionView.register(ActorCollectionViewCell.self, forCellWithReuseIdentifier: Section.actors.cellIdentifier)
    configure(moviesCollectionView)
    configure(actorsCollectionView)
  }
  
  func setupUI() {
    
    configureCollectionView()

    view.backgroundColor = UIColor(hexString: "#f7f8fa")
    
    let stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    stackView.spacing = .px16 / 2
    
    view.addSubview(stackView)
    
    stackView.pin(to: view.safeAreaLayoutGuide)
    
    searchBar.searchBarStyle = .minimal
    searchBar.heightAnchor.constraint(equalToConstant: 44).isActive = true
    
    moviesCollectionView.translatesAutoresizingMaskIntoConstraints = false
    moviesCollectionView.heightAnchor.constraint(equalToConstant: 200).isActive = true
    
    actorsCollectionView.translatesAutoresizingMaskIntoConstraints = false
    actorsCollectionView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    let moviesTitleLabel = UILabel(frame: .zero)
    moviesTitleLabel.text = "   Movies"
    moviesTitleLabel.font = .systemFont(ofSize: 15, weight: .black)
    moviesTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    
    let actorsTitleLabel = UILabel(frame: .zero)
    actorsTitleLabel.text = "   Actors"
    actorsTitleLabel.font = .systemFont(ofSize: 15, weight: .black)
    actorsTitleLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    
    stackView.addArrangedSubview(searchBar)
    stackView.addArrangedSubview(moviesTitleLabel)
    stackView.addArrangedSubview(moviesCollectionView)
    let spacer = UIView()
    spacer.translatesAutoresizingMaskIntoConstraints = false
    spacer.heightAnchor.constraint(equalToConstant: 20).isActive = true
    stackView.addSubview(spacer)
    stackView.addArrangedSubview(actorsTitleLabel)
    stackView.addArrangedSubview(actorsCollectionView)
    stackView.addArrangedSubview(UIView())
    
  }

}

extension MultiIndexDemoViewController {
  
  enum Section: Int {
    
    case shopItems
    case actors
    
    init?(section: Int) {
      self.init(rawValue: section)
    }
    
    init?(indexPath: IndexPath) {
      self.init(rawValue: indexPath.section)
    }
    
    var title: String {
      switch self {
      case .actors:
        return "Actors"
      case .shopItems:
        return "Movies"
      }
    }
    
    var index: Index {
      switch self {
      case .actors:
        return .demo(withName: "mobile_demo_actors")
        
      case .shopItems:
        return .demo(withName: "mobile_demo_movies")
      }
    }
    
    var cellIdentifier: String {
      switch self {
      case .actors:
        return "actorCell"
      case .shopItems:
        return "movieCell"
      }
    }
    
  }
  
}

extension MultiIndexDemoViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    guard let section = self.section(for: collectionView) else { return 0 }
    return hitsSource?.numberOfHits(inSection: section.rawValue) ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    guard let section = self.section(for: collectionView) else { return UICollectionViewCell() }
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: section.cellIdentifier, for: indexPath)
    
    switch section {
    case .shopItems:
      if let item: Movie = try? hitsSource?.hit(atIndex: indexPath.row, inSection: section.rawValue),
        let cell = cell as? HitCollectionViewCell {
        HitViewModel.movie(item).configure(cell.hitView)
      }
      
    case .actors:
      if let actor: Hit<Actor> = try? hitsSource?.hit(atIndex: indexPath.row, inSection: section.rawValue) {
        (cell as? ActorCollectionViewCell).flatMap(ActorHitCollectionViewCellViewState().configure)?(actor)
      }
    }

    return cell
  }
  
}

extension MultiIndexDemoViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    return UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }

  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
    return 10
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    guard let section = section(for: collectionView) else { return .zero }
    switch section {
    case .shopItems:
      return CGSize(width: collectionView.bounds.width / 2 - 10, height: collectionView.bounds.height - 10)

    case .actors:
      return CGSize(width: collectionView.bounds.width / 3, height: 40)
    }
  }

}

